class ApiBase {
  // Base URLs
  static const authUrl = 'https://auth-api.dev.jarvis.cx';
  static const jarvisUrl = 'https://api.dev.jarvis.cx';
  static const knowledgeUrl = 'https://knowledge-api.dev.jarvis.cx';

  // Other URLs
  static const verificationCallbackUrl =
      'https://auth.dev.jarvis.cx/handler/email-verification?after_auth_return_to=%2Fauth%2Fsignin%3Fclient_id%3Djarvis_chat%26redirect%3Dhttps%253A%252F%252Fchat.dev.jarvis.cx%252Fauth%252Foauth%252Fsuccess';
  static const headerAuth = {
    'X-Stack-Access-Type': 'client',
    'X-Stack-Project-Id': 'a914f06b-5e46-4966-8693-80e4b9f4f409',
    'X-Stack-Publishable-Client-Key':
        'pck_tqsy29b64a585km2g4wnpc57ypjprzzdch8xzpq0xhayr',
    'Content-Type': 'application/json',
  };
}
