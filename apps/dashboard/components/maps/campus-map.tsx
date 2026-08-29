'use client';

import { useEffect, useRef, useState } from 'react';
import type { MapMarker } from '@/types/map';
import { CAMPUS_BLOCKS } from '@/lib/maps';

export type MapViewType = 'streets' | 'satellite' | 'hybrid' | 'dark' | 'light' | 'terrain';

interface CampusMapProps {
  markers?: MapMarker[];
  className?: string;
  defaultView?: MapViewType;
  showViewSelector?: boolean;
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
}: CampusMapProps) {
  const mapContainerRef = useRef<HTMLDivElement>(null);
  const mapInstanceRef = useRef<any>(null);
  const markersLayerGroupRef = useRef<any>(null);
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
        const defaultCenter: [number, number] = [6.8905, 79.8820];

        const map = L.map(mapContainerRef.current, {
          center: defaultCenter,
          zoom: 16,
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
        mapInstanceRef.current = map;
      }

      // Update markers on the map
      if (mapInstanceRef.current && markersLayerGroupRef.current) {
        markersLayerGroupRef.current.clearLayers();

        const latLngs: [number, number][] = [];

        // Add campus blocks as markers
        CAMPUS_BLOCKS.forEach((block) => {
          if (block.latitude && block.longitude) {
            latLngs.push([block.latitude, block.longitude]);
            const isDark = currentView === 'dark' || currentView === 'satellite';
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

            const markerColor = isIncident ? '#ba1a1a' : isResponder ? '#00236f' : '#10b981';
            const markerEmoji = isIncident ? '🚨' : isResponder ? '🛡️' : '📡';

            const customIcon = L.divIcon({
              className: 'custom-live-marker',
              html: `
                <div style="position: relative; display: flex; align-items: center; justify-content: center; width: 34px; height: 34px;">
                  ${
                    isIncident
                      ? `<div style="
                          position: absolute;
                          width: 32px;
                          height: 32px;
                          border-radius: 50%;
                          background: rgba(186, 26, 26, 0.35);
                          animation: ping 1.5s cubic-bezier(0, 0, 0.2, 1) infinite;
                        "></div>`
                      : ''
                  }
                  <div style="
                    width: 28px;
                    height: 28px;
                    border-radius: 50%;
                    background: ${markerColor};
                    border: 2px solid #ffffff;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                    font-size: 13px;
                    box-shadow: 0 2px 6px rgba(0,0,0,0.3);
                  ">
                    ${markerEmoji}
                  </div>
                </div>
              `,
              iconSize: [34, 34],
              iconAnchor: [17, 17],
            });

            L.marker([marker.latitude, marker.longitude], { icon: customIcon })
              .bindPopup(`
                <div style="font-family: sans-serif; font-size: 12px; padding: 2px;">
                  <strong style="color: ${markerColor};">${marker.label}</strong><br/>
                  <span>Type: ${marker.type.toUpperCase()}</span><br/>
                  <span>Coordinates: ${marker.latitude.toFixed(4)}, ${marker.longitude.toFixed(4)}</span>
                </div>
              `)
              .addTo(markersLayerGroupRef.current);
          }
        });

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
  }, [markers, currentView]);

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

      {/* Interactive Legend Overlay */}
      <div className="absolute bottom-4 left-4 bg-surface-container-lowest/90 backdrop-blur-sm rounded-lg shadow-lg p-3 text-xs border border-outline-variant z-10 pointer-events-auto">
        <p className="font-label-md text-label-md text-on-surface mb-2 font-bold">CampusSafe Live Map</p>
        <div className="space-y-1.5">
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

