import { LitElement, html, css } from 'lit';
import { customElement, property } from 'lit/decorators.js';
import { classMap } from 'lit/directives/class-map.js';
import chroma from 'chroma-js';

@customElement('hello-world')
export class HelloWorld extends LitElement {
  static styles = css`
    :host {
      display: block;
      padding: 16px;
      font-family: sans-serif;
    }

    .container {
      border: 2px solid #ddd;
      border-radius: 8px;
      padding: 20px;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      color: white;
      transition: all 0.3s ease;
    }

    .container:hover {
      transform: translateY(-2px);
      box-shadow: 0 10px 20px rgba(0, 0, 0, 0.2);
    }

    .highlight {
      background-color: rgba(255, 255, 255, 0.2);
      padding: 4px 8px;
      border-radius: 4px;
    }

    .color-demo {
      margin-top: 10px;
      padding: 10px;
      border-radius: 4px;
      font-size: 14px;
    }
  `;

  @property({ type: String })
  name = 'World';

  @property({ type: Boolean })
  highlighted = false;

  private getColorInfo() {
    const color = chroma.random();
    return {
      hex: color.hex(),
      rgb: color.rgb().join(', '),
      hsl: color.hsl().map((v, i) => (i === 0 ? Math.round(v) : `${Math.round(v * 100)}%`)).join(', '),
    };
  }

  render() {
    const colorInfo = this.getColorInfo();
    const classes = { container: true, highlight: this.highlighted };

    return html`
      <div class=${classMap(classes)}>
        <h2>Hello, ${this.name}!</h2>
        <p>This is a Lit component with TypeScript</p>
        <button @click=${this.toggleHighlight}>Toggle Highlight</button>

        <div class="color-demo" style="background-color: ${colorInfo.hex}">
          <strong>Random Color (chroma-js):</strong><br>
          HEX: ${colorInfo.hex}<br>
          RGB: ${colorInfo.rgb}<br>
          HSL: ${colorInfo.hsl}
        </div>
      </div>
    `;
  }

  private toggleHighlight() {
    this.highlighted = !this.highlighted;
    console.log(`Highlight toggled: ${this.highlighted}`);
  }
}