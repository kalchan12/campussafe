'use client';

import type { MapMarker } from '@/types/map';
import { CAMPUS_BLOCKS } from '@/lib/maps';

interface CampusMapProps {
  markers?: MapMarker[];
  className?: string;
}

export function CampusMap({ markers = [], className }: CampusMapProps) {
  return (
    <div className={`bg-surface-variant rounded-lg overflow-hidden ${className}`}>
      <div className="relative w-full h-full min-h-[400px]">
        {/* Campus outline */}
        <svg
          viewBox="0 0 100 100"
          className="w-full h-full"
          preserveAspectRatio="xMidYMid meet"
        >
          {/* Grid lines */}
          {Array.from({ length: 11 }).map((_, i) => (
            <g key={i}>
              <line
                x1={i * 10}
                y1={0}
                x2={i * 10}
                y2={100}
                stroke="#c5c5d3"
                strokeWidth={0.3}
                opacity={0.5}
              />
              <line
                x1={0}
                y1={i * 10}
                x2={100}
                y2={i * 10}
                stroke="#c5c5d3"
                strokeWidth={0.3}
                opacity={0.5}
              />
            </g>
          ))}

          {/* Campus blocks */}
          {CAMPUS_BLOCKS.map((block) => {
            const x = ((block.longitude - 79.8800) / 0.005) * 100;
            const y = ((6.8920 - block.latitude) / 0.005) * 100;
            return (
              <g key={block.id}>
                <rect
                  x={x - 5}
                  y={y - 3}
                  width={10}
                  height={6}
                  fill="#dce1ff"
                  stroke="#264191"
                  strokeWidth={0.4}
                  rx={1}
                  opacity={0.7}
                />
                <text
                  x={x}
                  y={y + 0.5}
                  textAnchor="middle"
                  fontSize={1.8}
                  fill="#00236f"
                  fontWeight={500}
                >
                  {block.name}
                </text>
              </g>
            );
          })}

          {/* Markers */}
          {markers.map((marker) => {
            const x = ((marker.longitude - 79.8800) / 0.005) * 100;
            const y = ((6.8920 - marker.latitude) / 0.005) * 100;
            const isIncident = marker.type === 'incident';
            const isResponder = marker.type === 'responder';
            const fillColor = isIncident ? '#ba1a1a' : isResponder ? '#00236f' : '#10b981';

            return (
              <g key={marker.id}>
                {/* Pulse ring for incidents */}
                {isIncident && (
                  <circle
                    cx={x}
                    cy={y}
                    r={3.5}
                    fill="none"
                    stroke={fillColor}
                    strokeWidth={0.3}
                    opacity={0.3}
                  >
                    <animate
                      attributeName="r"
                      values="2;4;2"
                      dur="2s"
                      repeatCount="indefinite"
                    />
                    <animate
                      attributeName="opacity"
                      values="0.5;0;0.5"
                      dur="2s"
                      repeatCount="indefinite"
                    />
                  </circle>
                )}
                <circle
                  cx={x}
                  cy={y}
                  r={2}
                  fill={fillColor}
                  stroke="#ffffff"
                  strokeWidth={0.6}
                />
                <text
                  x={x}
                  y={y + 4}
                  textAnchor="middle"
                  fontSize={1.4}
                  fill="#1a1b21"
                  fontWeight={500}
                >
                  {marker.label}
                </text>
              </g>
            );
          })}
        </svg>

        {/* Legend */}
        <div className="absolute bottom-4 left-4 bg-surface-container-lowest rounded-lg shadow-lg p-3 text-xs border border-outline-variant">
          <p className="font-label-md text-label-md text-on-surface mb-2">Legend</p>
          <div className="space-y-1.5">
            <div className="flex items-center gap-2">
              <div className="w-3 h-3 rounded-full bg-error" />
              <span className="font-technical-sm text-technical-sm text-on-surface-variant">Incident</span>
            </div>
            <div className="flex items-center gap-2">
              <div className="w-3 h-3 rounded-full bg-primary" />
              <span className="font-technical-sm text-technical-sm text-on-surface-variant">Responder</span>
            </div>
            <div className="flex items-center gap-2">
              <div className="w-3 h-3 rounded-full bg-emerald-500" />
              <span className="font-technical-sm text-technical-sm text-on-surface-variant">Device</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
