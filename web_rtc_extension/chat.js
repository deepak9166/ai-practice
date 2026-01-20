/**
 * Chat Module
 * Handles chat message formatting and display
 */

class ChatManager {
  constructor(containerId) {
    this.container = document.getElementById(containerId);
    if (!this.container) {
      throw new Error(`Chat container with id "${containerId}" not found`);
    }
  }

  /**
   * Create chat message object
   */
  static createMessage(message, sender = 'extension') {
    return {
      type: 'chat',
      message: message,
      timestamp: Math.floor(Date.now() / 1000),
      sender: sender
    };
  }

  /**
   * Parse incoming message
   */
  static parseMessage(data) {
    try {
      if (typeof data === 'string') {
        return JSON.parse(data);
      }
      return data;
    } catch (error) {
      // If not JSON, treat as plain text
      return {
        type: 'chat',
        message: data,
        timestamp: Math.floor(Date.now() / 1000),
        sender: 'peer'
      };
    }
  }

  /**
   * Display message in chat UI
   */
  displayMessage(messageObj) {
    const messageDiv = document.createElement('div');
    messageDiv.className = 'message';

    const isSent = messageObj.sender === 'extension';
    messageDiv.classList.add(isSent ? 'sent' : 'received');

    const messageText = document.createElement('div');
    messageText.textContent = messageObj.message || messageObj;
    messageDiv.appendChild(messageText);

    if (messageObj.timestamp) {
      const timeText = document.createElement('div');
      timeText.className = 'message-time';
      const date = new Date(messageObj.timestamp * 1000);
      timeText.textContent = date.toLocaleTimeString();
      messageDiv.appendChild(timeText);
    }

    this.container.appendChild(messageDiv);
    this.container.scrollTop = this.container.scrollHeight;
  }

  /**
   * Clear chat messages
   */
  clear() {
    this.container.innerHTML = '';
  }

  /**
   * Format timestamp
   */
  static formatTimestamp(timestamp) {
    const date = new Date(timestamp * 1000);
    return date.toLocaleTimeString();
  }
}

// Make ChatManager available globally
window.ChatManager = ChatManager;

