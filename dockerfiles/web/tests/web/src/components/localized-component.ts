import { LitElement, html, css } from 'lit';
import { customElement, state } from 'lit/decorators.js';
import { msg, str, localized } from '@lit/localize';
import { getLocale, setLocale } from '../app';

@localized()
@customElement('localized-component')
export class LocalizedComponent extends LitElement {
  static styles = css`
    :host {
      display: block;
      margin: 20px 0;
      padding: 16px;
      border: 1px solid #e0e0e0;
      border-radius: 8px;
      background-color: #f9f9f9;
    }

    h3 {
      color: #333;
      margin-top: 0;
    }

    .locale-selector {
      margin: 10px 0;
    }

    select {
      padding: 5px 10px;
      border: 1px solid #ccc;
      border-radius: 4px;
      font-size: 14px;
    }

    .greeting {
      font-size: 18px;
      color: #666;
      margin: 10px 0;
    }

    .count-display {
      background: #fff;
      padding: 10px;
      border-radius: 4px;
      margin: 10px 0;
    }

    button {
      background: #4caf50;
      color: white;
      border: none;
      padding: 8px 16px;
      border-radius: 4px;
      cursor: pointer;
      margin-right: 8px;
    }

    button:hover {
      background: #45a049;
    }
  `;

  @state()
  private count = 0;

  @state()
  private currentLocale = getLocale();

  @state()
  private userName = 'Developer';

  render() {
    return html`
      <h3>${msg('Localization Demo')}</h3>

      <div class="locale-selector">
        <label for="locale-select">${msg('Select Language')}:</label>
        <select id="locale-select" @change=${this.handleLocaleChange}>
          <option value="en" ?selected=${this.currentLocale === 'en'}>English</option>
          <option value="es" ?selected=${this.currentLocale === 'es'}>Español</option>
          <option value="fr" ?selected=${this.currentLocale === 'fr'}>Français</option>
          <option value="de" ?selected=${this.currentLocale === 'de'}>Deutsch</option>
          <option value="ja" ?selected=${this.currentLocale === 'ja'}>日本語</option>
        </select>
      </div>

      <div class="greeting">
        ${msg(str`Welcome, ${this.userName}!`)}
      </div>

      <div class="count-display">
        <p>${msg(str`You have clicked ${this.count} times`)}</p>
        <button @click=${this.increment}>${msg('Click me')}</button>
        <button @click=${this.reset}>${msg('Reset')}</button>
      </div>

      <p>${msg('This component demonstrates localization with @lit/localize')}</p>
    `;
  }

  private async handleLocaleChange(event: Event) {
    const newLocale = (event.target as HTMLSelectElement).value;
    await setLocale(newLocale);
    this.currentLocale = newLocale;
  }

  private increment() {
    this.count++;
  }

  private reset() {
    this.count = 0;
  }
}