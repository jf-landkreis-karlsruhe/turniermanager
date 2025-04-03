// Configuration file for Tournament Manager admin panel

const CONFIG = {
    // API endpoints (relative to base URL)
    endpoints: {
        tournament: '/turniersetup/create',
        qualification: '/turniersetup/create/qualification',
        ageGroups: '/turniersetup/agegroups',
        teams: '/turniersetup/teams',
        pitches: '/turniersetup/pitches'
    },
    
    // Get full API URL for an endpoint
    getApiUrl: function(endpoint) {
        return BASE_API_URL + (this.endpoints[endpoint] || endpoint);
    }
};
