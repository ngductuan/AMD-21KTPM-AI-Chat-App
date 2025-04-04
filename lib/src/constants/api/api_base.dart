class ApiBase {
  // Base URLs
  static const authUrl = 'https://auth-api.jarvis.cx';
  static const jarvisUrl = 'https://api.dev.jarvis.cx';
  static const knowledgeUrl = 'https://knowledge-api.dev.jarvis.cx';

  // Other URLs
  static const verificationCallbackUrl = 'https://auth.dev.jarvis.cx/handler/email-verification?after_auth_return_to=%2Fauth%2Fsignin%3Fclient_id%3Djarvis_chat%26redirect%3Dhttps%253A%252F%252Fchat.dev.jarvis.cx%252Fauth%252Foauth%252Fsuccess';
  static const headerAuth = {
      'X-Stack-Access-Type': 'client',
      'X-Stack-Project-Id': '45a1e2fd-77ee-4872-9fb7-987b8c119633',
      'X-Stack-Publishable-Client-Key':
          'pck_7wjweasxxnfspvr20dvmyd9pjj0p9kp755bxxcm4ae1er',
      'Content-Type': 'application/json',
    };
}