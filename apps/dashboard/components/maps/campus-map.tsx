'use client';

import { useEffect, useRef } from 'react';
import type { MapMarker } from '@/types/map';
import { CAMPUS_BLOCKS } from '@/lib/maps';

interface CampusMapProps {
  markers?: MapMarker[];
  className?: string;
}

export function CampusMap({ markers = [], className = '' }: CampusMapProps) {
  const mapContainerRef = useRef<HTMLDivElement>(null);
  const mapInstanceRef = useRef<any>(null);
  const markersLayerGroupRef = useRef<any>(null);

  useEffect(() => {
    let isMounted = true;

    async function initMap() {
      if (typeof window === 'undefined' || !mapContainerRef.current) return;

      const L = (await import('leaflet')).default;

      if (!isMounted) return;

      if (!mapInstanceRef.current && mapContainerRef.current) {
        // Fallback default coordinates (Stanford / Campus Quad)
        const defaultCenter: [number, number] = [37.4275, -122.1697];

        const map = L.map(mapContainerRef.current, {
          center: defaultCenter,
          zoom: 16,
          zoomControl: true,
        });

        L.tileLayer('https://tile.openstreetmap.org/{z}/{x}/{y}.png', {
          attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a> contributors',
          maxZoom: 19,
        }).addTo(map);

        const markersLayer = L.layerGroup().addTo(map);
        markersLayerGroupRef.current = markersLayer;
        mapInstanceRef.current = map;
      }

      // Update markers on the map
      if (mapInstanceRef.current && markersLayerGroupRef.current) {
        markersLayerGroupRef.current.clearLayers();

        const latLngs: [number, number][] = [];

        // Add campus blocks as polygons/rectangles or labels
        CAMPUS_BLOCKS.forEach((block) => {
          if (block.latitude && block.longitude) {
            const blockIcon = L.divIcon({
              className: 'custom-block-marker',
              html: `
                <div style="
                  background: rgba(38, 65, 145, 0.12);
                  border: 1.5px solid #264191;
                  border-radius: 6px;
                  padding: 2px 6px;
                  font-size: 10px;
                  font-weight: 700;
                  color: #00236f;
                  white-space: nowrap;
                  text-align: center;
                  box-shadow: 0 1px 3px rgba(0,0,0,0.15);
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
            mapInstanceRef.current.fitBounds(latLngs, { padding: [40, 40], maxZoom: 17 });
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
  }, [markers]);

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

      {/* Interactive Legend Overlay */}
      <div className="absolute bottom-4 left-4 bg-surface-container-lowest/90 backdrop-blur-sm rounded-lg shadow-lg p-3 text-xs border border-outline-variant z-10 pointer-events-auto">
        <p className="font-label-md text-label-md text-on-surface mb-2 font-bold">CampusSafe Live Map</p>
        <div className="space-y-1.5">
          <div className="flex items-center gap-2">
            <div className="w-3 h-3 rounded-full bg-error" />
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
