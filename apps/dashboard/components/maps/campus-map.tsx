'use client';

import { useEffect, useRef, useState } from 'react';
import type { MapMarker } from '@/types/map';
import {
  CAMPUS_BLOCKS,
  ADAMA_CENTER,
  ADAMA_CAMPUS_BOUNDS,
  ADAMA_UNIVERSITY_CAMPUS_POLYGON,
  getBestRoute,
  type RouteGeoJson,
} from '@/lib/maps';

export type MapViewType = 'streets' | 'satellite' | 'hybrid' | 'dark' | 'light' | 'terrain';

export interface OperatorLocation {
  latitude: number;
  longitude: number;
  accuracy?: number;
  isLive?: boolean;
}

interface CampusMapProps {
  markers?: MapMarker[];
  className?: string;
  defaultView?: MapViewType;
  showViewSelector?: boolean;
  operatorLocation?: OperatorLocation | null;
  selectedMarkerId?: string | null;
  onMarkerClick?: (marker: MapMarker) => void;
  onRecenterOperator?: () => void;
  onRouteCalculated?: (route: RouteGeoJson | null) => void;
}

export const MAP_VIEW_TILES: Record<
  MapViewType,
  { name: string; url: string; attribution: string; icon: string; maxZoom: number }
> = {
  streets: {
    name: 'Standard',
    icon: 'map',
    url: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
    attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
    maxZoom: 19,
  },
  satellite: {
    name: 'Satellite',
    icon: 'satellite_alt',
    url: 'https://server.arcgisonline.com/ArcGIS/rest/services/World_Imagery/MapServer/tile/{z}/{y}/{x}',
    attribution: 'Tiles &copy; Esri &mdash; Source: Esri, i-cubed, USDA, USGS, AEX, GeoEye, Getmapping, Aerogrid, IGN, IGP, UPR-EGP, and the GIS User Community',
    maxZoom: 18,
  },
  hybrid: {
    name: 'Hybrid',
    icon: 'layers',
    url: 'https://mt1.google.com/vt/lyrs=y&x={x}&y={y}&z={z}',
    attribution: '&copy; Google Maps',
    maxZoom: 20,
  },
  dark: {
    name: 'Dark Ops',
    icon: 'dark_mode',
    url: 'https://{s}.basemaps.cartocdn.com/dark_all/{z}/{x}/{y}{r}.png',
    attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> &copy; <a href="https://carto.com/attributions">CARTO</a>',
    maxZoom: 19,
  },
  light: {
    name: 'Blueprint',
    icon: 'light_mode',
    url: 'https://{s}.basemaps.cartocdn.com/light_all/{z}/{x}/{y}{r}.png',
    attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> &copy; <a href="https://carto.com/attributions">CARTO</a>',
    maxZoom: 19,
  },
  terrain: {
    name: 'Topography',
    icon: 'terrain',
    url: 'https://{s}.tile.opentopomap.org/{z}/{x}/{y}.png',
    attribution: 'Map data: &copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>, <a href="http://viewfinderpanoramas.org">SRTM</a> | Map style: &copy; <a href="https://opentopomap.org">OpenTopoMap</a>',
    maxZoom: 17,
  },
};

export function CampusMap({
  markers = [],
  className = '',
  defaultView = 'streets',
  showViewSelector = true,
  operatorLocation = null,
  selectedMarkerId = null,
  onMarkerClick,
  onRecenterOperator,
  onRouteCalculated,
}: CampusMapProps) {
  const mapContainerRef = useRef<HTMLDivElement>(null);
  const mapInstanceRef = useRef<any>(null);
  const markersLayerGroupRef = useRef<any>(null);
  const operatorLayerGroupRef = useRef<any>(null);
  const routeLineRef = useRef<any>(null);
  const tileLayerRef = useRef<any>(null);
  const [currentView, setCurrentView] = useState<MapViewType>(defaultView);

  // Initialize Map
  useEffect(() => {
    let isMounted = true;

    async function initMap() {
      if (typeof window === 'undefined' || !mapContainerRef.current) return;

      const L = (await import('leaflet')).default;

      if (!isMounted) return;

      if (!mapInstanceRef.current && mapContainerRef.current) {
        const defaultCenter: [number, number] = operatorLocation
          ? [operatorLocation.latitude, operatorLocation.longitude]
          : ADAMA_CENTER;

        const map = L.map(mapContainerRef.current, {
          center: defaultCenter,
          zoom: operatorLocation ? 17 : 16,
          minZoom: 13, // Keep locked to campus & Adama city level
          maxZoom: 19,
          maxBounds: ADAMA_CAMPUS_BOUNDS, // Prevent panning across the entire globe
          maxBoundsViscosity: 0.85,
          zoomControl: true,
        });

        const initialConfig = MAP_VIEW_TILES[currentView];
        const tileLayer = L.tileLayer(initialConfig.url, {
          attribution: initialConfig.attribution,
          maxZoom: initialConfig.maxZoom,
          subdomains: 'abcd',
        }).addTo(map);

        tileLayerRef.current = tileLayer;

        const markersLayer = L.layerGroup().addTo(map);
        markersLayerGroupRef.current = markersLayer;

        const operatorLayer = L.layerGroup().addTo(map);
        operatorLayerGroupRef.current = operatorLayer;

        const campusBoundaryLayer = L.layerGroup().addTo(map);

        // Highlight University Campus Perimeter Polygon
        L.polygon(ADAMA_UNIVERSITY_CAMPUS_POLYGON, {
          color: '#2563eb',
          weight: 2,
          dashArray: '5, 5',
          fillColor: '#3b82f6',
          fillOpacity: 0.08,
        })
          .bindPopup('<b>Adama University Campus Zone</b><br/>Monitored Safety Area')
          .addTo(campusBoundaryLayer);

        mapInstanceRef.current = map;
      }

      // Update Operator Location Beacon
      if (mapInstanceRef.current && operatorLayerGroupRef.current) {
        operatorLayerGroupRef.current.clearLayers();

        if (operatorLocation) {
          // Google Maps Blue Dot Marker with Accuracy Circle
          if (operatorLocation.accuracy && operatorLocation.accuracy > 0) {
            L.circle([operatorLocation.latitude, operatorLocation.longitude], {
              radius: Math.min(operatorLocation.accuracy, 100),
              color: '#4285F4',
              weight: 1,
              opacity: 0.4,
              fillColor: '#4285F4',
              fillOpacity: 0.12,
            }).addTo(operatorLayerGroupRef.current);
          }

          const operatorIcon = L.divIcon({
            className: 'operator-gps-dot',
            html: `
              <div style="position: relative; display: flex; align-items: center; justify-content: center; width: 36px; height: 36px;">
                <div style="
                  position: absolute;
                  width: 34px;
                  height: 34px;
                  border-radius: 50%;
                  background: rgba(66, 133, 244, 0.4);
                  animation: ping 1.8s cubic-bezier(0, 0, 0.2, 1) infinite;
                "></div>
                <div style="
                  width: 18px;
                  height: 18px;
                  border-radius: 50%;
                  background: #1a73e8;
                  border: 3px solid #ffffff;
                  box-shadow: 0 2px 8px rgba(0,0,0,0.35);
                  position: relative;
                  z-index: 2;
                "></div>
              </div>
            `,
            iconSize: [36, 36],
            iconAnchor: [18, 18],
          });

          L.marker([operatorLocation.latitude, operatorLocation.longitude], {
            icon: operatorIcon,
            zIndexOffset: 1000,
          })
            .bindPopup(`
              <div style="font-family: sans-serif; font-size: 12px; padding: 2px;">
                <strong style="color: #1a73e8;">📍 Operator Location (You)</strong><br/>
                <span style="font-size: 11px; color: #555;">Live GPS coordinates</span><br/>
                <span>${operatorLocation.latitude.toFixed(5)}, ${operatorLocation.longitude.toFixed(5)}</span>
              </div>
            `)
            .addTo(operatorLayerGroupRef.current);
        }
      }

      // Update markers on the map
      if (mapInstanceRef.current && markersLayerGroupRef.current) {
        markersLayerGroupRef.current.clearLayers();

        const latLngs: [number, number][] = [];

        if (operatorLocation) {
          latLngs.push([operatorLocation.latitude, operatorLocation.longitude]);
        }

        // Add campus blocks as markers
        CAMPUS_BLOCKS.forEach((block) => {
          if (block.latitude && block.longitude) {
            latLngs.push([block.latitude, block.longitude]);
            const isDark = currentView === 'dark' || currentView === 'satellite' || currentView === 'hybrid';
            const blockIcon = L.divIcon({
              className: 'custom-block-marker',
              html: `
                <div style="
                  background: ${isDark ? 'rgba(15, 23, 42, 0.85)' : 'rgba(255, 255, 255, 0.92)'};
                  border: 1.5px solid ${isDark ? '#60a5fa' : '#264191'};
                  border-radius: 6px;
                  padding: 2px 6px;
                  font-size: 10px;
                  font-weight: 700;
                  color: ${isDark ? '#93c5fd' : '#00236f'};
                  white-space: nowrap;
                  text-align: center;
                  box-shadow: 0 2px 4px rgba(0,0,0,0.25);
                ">
                  🏢 ${block.name}
                </div>
              `,
              iconSize: [80, 24],
              iconAnchor: [40, 12],
            });

            L.marker([block.latitude, block.longitude], { icon: blockIcon })
              .bindPopup(`<b>${block.name}</b><br/>Campus Building #${block.id}`)
              .addTo(markersLayerGroupRef.current);
          }
        });

        // Add dynamic markers (Incidents, Responders, Devices)
        markers.forEach((marker) => {
          if (marker.latitude && marker.longitude) {
            latLngs.push([marker.latitude, marker.longitude]);

            const isIncident = marker.type === 'incident';
            const isResponder = marker.type === 'responder';
            const isSelected = selectedMarkerId === marker.id;

            const markerColor = isIncident ? '#ba1a1a' : isResponder ? '#00236f' : '#10b981';
            const markerEmoji = isIncident ? '🚨' : isResponder ? '🛡️' : '📡';

            const customIcon = L.divIcon({
              className: `custom-live-marker ${isSelected ? 'scale-125' : ''}`,
              html: `
                <div style="position: relative; display: flex; align-items: center; justify-content: center; width: 38px; height: 38px; cursor: pointer;">
                  ${
                    isIncident
                      ? `<div style="
                          position: absolute;
                          width: 36px;
                          height: 36px;
                          border-radius: 50%;
                          background: rgba(186, 26, 26, 0.35);
                          animation: ping 1.5s cubic-bezier(0, 0, 0.2, 1) infinite;
                        "></div>`
                      : ''
                  }
                  ${
                    isSelected
                      ? `<div style="
                          position: absolute;
                          width: 44px;
                          height: 44px;
                          border-radius: 50%;
                          border: 2px dashed ${markerColor};
                          animation: spin 6s linear infinite;
                        "></div>`
                      : ''
                  }
                  <div style="
                    width: ${isSelected ? '32px' : '28px'};
                    height: ${isSelected ? '32px' : '28px'};
                    border-radius: 50%;
                    background: ${markerColor};
                    border: 2.5px solid #ffffff;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    font-size: ${isSelected ? '15px' : '13px'};
                    box-shadow: 0 2px 8px rgba(0,0,0,0.35);
                  ">
                    ${markerEmoji}
                  </div>
                </div>
              `,
              iconSize: [38, 38],
              iconAnchor: [19, 19],
            });

            const m = L.marker([marker.latitude, marker.longitude], {
              icon: customIcon,
              zIndexOffset: isSelected ? 500 : 0,
            });

            m.on('click', () => {
              onMarkerClick?.(marker);
            });

            m.bindPopup(`
              <div style="font-family: sans-serif; font-size: 12px; padding: 2px;">
                <strong style="color: ${markerColor};">${marker.label}</strong><br/>
                <span>Type: ${marker.type.toUpperCase()}</span><br/>
                <span>Coordinates: ${marker.latitude.toFixed(4)}, ${marker.longitude.toFixed(4)}</span>
              </div>
            `);

            m.addTo(markersLayerGroupRef.current);
          }
        });

        // Calculate and Draw Optimal Route from Operator to Selected Incident
        if (routeLineRef.current) {
          mapInstanceRef.current.removeLayer(routeLineRef.current);
          routeLineRef.current = null;
        }

        if (operatorLocation && selectedMarkerId) {
          const selectedMarker = markers.find((m) => m.id === selectedMarkerId);
          if (selectedMarker && selectedMarker.latitude && selectedMarker.longitude) {
            getBestRoute(
              operatorLocation.latitude,
              operatorLocation.longitude,
              selectedMarker.latitude,
              selectedMarker.longitude
            ).then((route) => {
              if (!isMounted || !mapInstanceRef.current) return;
              onRouteCalculated?.(route);

              if (routeLineRef.current) {
                mapInstanceRef.current.removeLayer(routeLineRef.current);
              }

              // Draw path polyline (with subtle glow and dashed style)
              const polyline = L.polyline(route.coordinates, {
                color: '#2563eb',
                weight: 4,
                opacity: 0.9,
                dashArray: route.isRealRoadRoute ? undefined : '6, 8',
                lineJoin: 'round',
              }).addTo(mapInstanceRef.current);

              routeLineRef.current = polyline;
            });
          } else {
            onRouteCalculated?.(null);
          }
        } else {
          onRouteCalculated?.(null);
        }

        // Auto-fit bounds if we have valid marker coordinates
        if (latLngs.length > 0) {
          try {
            mapInstanceRef.current.fitBounds(latLngs, { padding: [50, 50], maxZoom: 17 });
          } catch {
            // Keep default center
          }
        }
      }
    }

    initMap();

    return () => {
      isMounted = false;
    };
  }, [markers, currentView, operatorLocation, selectedMarkerId]);


  // Switch Tile Layer when currentView changes
  useEffect(() => {
    async function switchLayer() {
      if (!mapInstanceRef.current) return;
      const L = (await import('leaflet')).default;

      if (tileLayerRef.current) {
        mapInstanceRef.current.removeLayer(tileLayerRef.current);
      }

      const layerConfig = MAP_VIEW_TILES[currentView];
      const newTileLayer = L.tileLayer(layerConfig.url, {
        attribution: layerConfig.attribution,
        maxZoom: layerConfig.maxZoom,
        subdomains: 'abcd',
      }).addTo(mapInstanceRef.current);

      tileLayerRef.current = newTileLayer;
      // Keep tileLayer behind markers
      if (markersLayerGroupRef.current) {
        markersLayerGroupRef.current.bringToFront();
      }
    }

    switchLayer();
  }, [currentView]);

  useEffect(() => {
    return () => {
      if (mapInstanceRef.current) {
        mapInstanceRef.current.remove();
        mapInstanceRef.current = null;
      }
    };
  }, []);

  return (
    <div className={`relative bg-surface-variant rounded-lg overflow-hidden ${className}`}>
      {/* Map Target Container */}
      <div ref={mapContainerRef} className="w-full h-full min-h-[400px] z-0" />

      {/* Map Style Selector Overlay */}
      {showViewSelector && (
        <div className="absolute top-4 right-4 bg-surface-container-lowest/90 backdrop-blur-md rounded-xl shadow-lg p-1.5 border border-outline-variant z-10 flex items-center gap-1 pointer-events-auto">
          {(Object.keys(MAP_VIEW_TILES) as MapViewType[]).map((viewKey) => {
            const view = MAP_VIEW_TILES[viewKey];
            const isSelected = currentView === viewKey;
            return (
              <button
                key={viewKey}
                type="button"
                onClick={() => setCurrentView(viewKey)}
                title={`Switch to ${view.name} view`}
                className={`flex items-center gap-1.5 px-3 py-1.5 rounded-lg text-xs font-label-md transition-all duration-150 ${
                  isSelected
                    ? 'bg-primary text-on-primary font-bold shadow-sm'
                    : 'text-on-surface-variant hover:bg-surface-variant hover:text-on-surface'
                }`}
              >
                <span className="material-symbols-outlined text-sm">{view.icon}</span>
                <span>{view.name}</span>
              </button>
            );
          })}
        </div>
      )}

      {/* Locate Operator GPS Action Button */}
      {operatorLocation && (
        <div className="absolute bottom-28 left-4 z-10 pointer-events-auto">
          <button
            type="button"
            onClick={() => {
              if (mapInstanceRef.current && operatorLocation) {
                mapInstanceRef.current.flyTo(
                  [operatorLocation.latitude, operatorLocation.longitude],
                  18,
                  { animate: true, duration: 1 }
                );
              }
              onRecenterOperator?.();
            }}
            title="Recenter view on your exact GPS location"
            className="flex items-center gap-1.5 px-3 py-2 bg-surface-container-lowest/95 backdrop-blur-md rounded-xl shadow-lg border border-blue-200 text-blue-700 hover:bg-blue-50 text-xs font-label-md font-bold transition-all"
          >
            <span className="material-symbols-outlined text-base text-blue-600">my_location</span>
            <span>Focus My Location</span>
          </button>
        </div>
      )}

      {/* Interactive Legend Overlay */}
      <div className="absolute bottom-4 left-4 bg-surface-container-lowest/90 backdrop-blur-sm rounded-lg shadow-lg p-3 text-xs border border-outline-variant z-10 pointer-events-auto">
        <p className="font-label-md text-label-md text-on-surface mb-2 font-bold">CampusSafe Live Map</p>
        <div className="space-y-1.5">
          <div className="flex items-center gap-2">
            <div className="w-3 h-3 rounded-full bg-blue-600 animate-ping" />
            <span className="font-technical-sm text-on-surface-variant">Operator Location (You)</span>
          </div>
          <div className="flex items-center gap-2">
            <div className="w-3 h-3 rounded-full bg-error animate-pulse" />
            <span className="font-technical-sm text-on-surface-variant">Live Incident (Pulsing)</span>
          </div>
          <div className="flex items-center gap-2">
            <div className="w-3 h-3 rounded-full bg-primary" />
            <span className="font-technical-sm text-on-surface-variant">On-Duty Responder</span>
          </div>
          <div className="flex items-center gap-2">
            <div className="w-3 h-3 rounded-full bg-emerald-500" />
            <span className="font-technical-sm text-on-surface-variant">IoT SOS Station / Sensor</span>
          </div>
        </div>
      </div>
    </div>
  );
}

