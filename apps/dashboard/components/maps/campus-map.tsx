'use client';

import type { MapMarker } from '@/types/map';
import { CAMPUS_BLOCKS } from '@/lib/maps';

interface CampusMapProps {
  markers?: MapMarker[];
  className?: string;
}

export function CampusMap({ markers = [], className }: CampusMapProps) {
  return (
    <div className={`bg-gray-100 rounded-lg overflow-hidden ${className}`}>
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
                stroke="#e5e7eb"
                strokeWidth={0.5}
              />
              <line
                x1={0}
                y1={i * 10}
                x2={100}
                y2={i * 10}
                stroke="#e5e7eb"
                strokeWidth={0.5}
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
                  fill="#e0e7ff"
                  stroke="#6366f1"
                  strokeWidth={0.5}
                  rx={1}
                />
                <text
                  x={x}
                  y={y + 0.5}
                  textAnchor="middle"
                  fontSize={2}
                  fill="#4338ca"
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
            return (
              <g key={marker.id}>
                <circle
                  cx={x}
                  cy={y}
                  r={2}
                  fill={marker.color || '#3b82f6'}
                  stroke="white"
                  strokeWidth={0.5}
                />
                <text
                  x={x}
                  y={y + 4}
                  textAnchor="middle"
                  fontSize={1.5}
                  fill="#374151"
                >
                  {marker.label}
                </text>
              </g>
            );
          })}
        </svg>

        {/* Legend */}
        <div className="absolute bottom-4 left-4 bg-white rounded-lg shadow-lg p-3 text-xs">
          <p className="font-medium text-gray-700 mb-2">Legend</p>
          <div className="space-y-1">
            <div className="flex items-center gap-2">
              <div className="w-3 h-3 rounded-full bg-red-500"></div>
              <span>Incident</span>
            </div>
            <div className="flex items-center gap-2">
              <div className="w-3 h-3 rounded-full bg-green-500"></div>
              <span>Responder</span>
            </div>
            <div className="flex items-center gap-2">
              <div className="w-3 h-3 rounded-full bg-blue-500"></div>
              <span>Device</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  );
}
