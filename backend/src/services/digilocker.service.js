/**
 * Mock DigiLocker Service
 * Simulates fetching verified documents via DigiLocker OAuth2 API
 */
const fetchDigiLockerDocuments = async (otrId) => {
  // Simulate network delay for OAuth2 API call
  await new Promise((resolve) => setTimeout(resolve, 1500));

  // In a real scenario, we would use an OAuth access token to fetch documents.
  // Here we return mock metadata simulating government API responses.
  return [
    {
      documentType: 'INCOME_CERT',
      digilockerUri: `dl://cert/income/${otrId}/987654321`,
      isVerified: true,
      fetchedAt: new Date()
    },
    {
      documentType: 'CASTE_CERT',
      digilockerUri: `dl://cert/caste/${otrId}/123456789`,
      isVerified: true,
      fetchedAt: new Date()
    }
  ];
};

module.exports = {
  fetchDigiLockerDocuments
};
