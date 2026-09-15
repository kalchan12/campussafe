/** @type {import('next').NextConfig} */
const nextConfig = {
  reactStrictMode: true,
  async redirects() {
    return [
      {
        source: '/map',
        destination: '/dashboard/map',
        permanent: false,
      },
      {
        source: '/incidents',
        destination: '/dashboard/incidents',
        permanent: false,
      },
      {
        source: '/responders',
        destination: '/dashboard/responders',
        permanent: false,
      },
      {
        source: '/devices',
        destination: '/dashboard/devices',
        permanent: false,
      },
      {
        source: '/reports',
        destination: '/dashboard/reports',
        permanent: false,
      },
      {
        source: '/users',
        destination: '/dashboard/users',
        permanent: false,
      },
      {
        source: '/settings',
        destination: '/dashboard/settings',
        permanent: false,
      },
    ];
  },
};

module.exports = nextConfig;
