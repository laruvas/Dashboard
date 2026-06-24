#!/usr/bin/env bash
set -euo pipefail

# Full quality refactor installer for Slottr/Dashboard.
# Run from repository root.

if [ ! -f "package.json" ] || [ ! -d "src" ]; then
  echo "Run this script from repository root" >&2
  exit 1
fi

BACKUP_DIR=".quality-refactor-backup-$(date +%Y%m%d%H%M%S)"
mkdir -p "$BACKUP_DIR"

backup_file() {
  local path="$1"
  if [ -f "$path" ]; then
    mkdir -p "$BACKUP_DIR/$(dirname "$path")"
    cp "$path" "$BACKUP_DIR/$path"
  fi
}

write_file() {
  local path="$1"
  backup_file "$path"
  mkdir -p "$(dirname "$path")"
  cat > "$path"
}

echo "Installing quality refactor files..."

write_file 'package-lock.json' <<'QUALITY_REFACTOR_FILE'
{
  "name": "slottr-app",
  "version": "0.1.0",
  "lockfileVersion": 3,
  "requires": true,
  "packages": {
    "": {
      "name": "slottr-app",
      "version": "0.1.0",
      "dependencies": {
        "@libsql/client": "^0.17.3",
        "bcryptjs": "^3.0.3",
        "react": "^18.3.1",
        "react-dom": "^18.3.1",
        "react-router-dom": "^6.26.0"
      },
      "devDependencies": {
        "@types/bcryptjs": "^2.4.6",
        "@types/react": "^19.2.17",
        "@types/react-dom": "^19.2.3",
        "@vitejs/plugin-react": "^6.0.3",
        "@vitest/coverage-v8": "^4.1.9",
        "concurrently": "^10.0.3",
        "cors": "^2.8.6",
        "express": "^4.22.2",
        "jsonwebtoken": "^9.0.3",
        "supertest": "^7.0.0",
        "typescript": "^6.0.3",
        "vite": "^8.1.0",
        "vitest": "^4.1.9"
      },
      "engines": {
        "node": ">=20"
      }
    },
    "node_modules/@babel/helper-string-parser": {
      "version": "7.29.7",
      "resolved": "https://registry.npmjs.org/@babel/helper-string-parser/-/helper-string-parser-7.29.7.tgz",
      "integrity": "sha512-Pb5ijPrZ89GDH8223L4UP8i6QApWxs04RbPQJTeWDV0/keR2E36MeKnyr6LYmUUvqRRI+Iv87SuF1W6ErINzYw==",
      "dev": true,
      "license": "MIT",
      "engines": {
        "node": ">=6.9.0"
      }
    },
    "node_modules/@babel/helper-validator-identifier": {
      "version": "7.29.7",
      "resolved": "https://registry.npmjs.org/@babel/helper-validator-identifier/-/helper-validator-identifier-7.29.7.tgz",
      "integrity": "sha512-qehxGkRj55h/ff8EMaJ+cYhyaKlHIxqYDn682wQD7RNp9UujOQsHog2uS0r2vzr4pW+sXf90NeeayjcNaX3fFg==",
      "dev": true,
      "license": "MIT",
      "engines": {
        "node": ">=6.9.0"
      }
    },
    "node_modules/@babel/parser": {
      "version": "7.29.7",
      "resolved": "https://registry.npmjs.org/@babel/parser/-/parser-7.29.7.tgz",
      "integrity": "sha512-hnORnjP/1P/zFEndoeX+n+t1RwWRJiJpM/jO7FW32Kn9r5+sJB2JWOdYo4L6k78j15eCwY3Gm/7364B1EMwtNg==",
      "dev": true,
      "license": "MIT",
      "dependencies": {
        "@babel/types": "^7.29.7"
      },
      "bin": {
        "parser": "bin/babel-parser.js"
      },
      "engines": {
        "node": ">=6.0.0"
      }
    },
    "node_modules/@babel/types": {
      "version": "7.29.7",
      "resolved": "https://registry.npmjs.org/@babel/types/-/types-7.29.7.tgz",
      "integrity": "sha512-4zBIxpPzowiZpusoFkyGVwakdRJUyuH5PxQ/PrqghfdFWWasvnCdPfQXHrenDai+gyLARulZjZowCOj6fjT4pA==",
      "dev": true,
      "license": "MIT",
      "dependencies": {
        "@babel/helper-string-parser": "^7.29.7",
        "@babel/helper-validator-identifier": "^7.29.7"
      },
      "engines": {
        "node": ">=6.9.0"
      }
    },
    "node_modules/@bcoe/v8-coverage": {
      "version": "1.0.2",
      "resolved": "https://registry.npmjs.org/@bcoe/v8-coverage/-/v8-coverage-1.0.2.tgz",
      "integrity": "sha512-6zABk/ECA/QYSCQ1NGiVwwbQerUCZ+TQbp64Q3AgmfNvurHH0j8TtXa1qbShXA6qqkpAj4V5W8pP6mLe1mcMqA==",
      "dev": true,
      "license": "MIT",
      "engines": {
        "node": ">=18"
      }
    },
    "node_modules/@emnapi/core": {
      "version": "1.11.1",
      "resolved": "https://registry.npmjs.org/@emnapi/core/-/core-1.11.1.tgz",
      "integrity": "sha512-RSvbQmHzdKzNsLYa/wHrbc3KN4sYLKAdPZxqiM2HATqv/SBk2/ENSHpvXGaLOMcsAyz0poEGqkmmKYG3OWiJEQ==",
      "dev": true,
      "license": "MIT",
      "optional": true,
      "dependencies": {
        "@emnapi/wasi-threads": "1.2.2",
        "tslib": "^2.4.0"
      }
    },
    "node_modules/@emnapi/runtime": {
      "version": "1.11.1",
      "resolved": "https://registry.npmjs.org/@emnapi/runtime/-/runtime-1.11.1.tgz",
      "integrity": "sha512-vgj7R3y3Wgx24IQaGPA/R6YFXLHVMOZ0uVEyIQPaWs+rd1AzfEMXlAC22FYwO1XkKR6NPsq7mUandH8oIRdZFw==",
      "dev": true,
      "license": "MIT",
      "optional": true,
      "dependencies": {
        "tslib": "^2.4.0"
      }
    },
    "node_modules/@emnapi/wasi-threads": {
      "version": "1.2.2",
      "resolved": "https://registry.npmjs.org/@emnapi/wasi-threads/-/wasi-threads-1.2.2.tgz",
      "integrity": "sha512-c95qOXkHdydNKhscBTebqEC1CVAZpyqOfVfBzQ1qgzyl3gfeldUjIggDbIZgDKsHLgnsM+igH7TJ/eAasaVuMA==",
      "dev": true,
      "license": "MIT",
      "optional": true,
      "dependencies": {
        "tslib": "^2.4.0"
      }
    },
    "node_modules/@jridgewell/resolve-uri": {
      "version": "3.1.2",
      "resolved": "https://registry.npmjs.org/@jridgewell/resolve-uri/-/resolve-uri-3.1.2.tgz",
      "integrity": "sha512-bRISgCIjP20/tbWSPWMEi54QVPRZExkuD9lJL+UIxUKtwVJA8wW1Trb1jMs1RFXo1CBTNZ/5hpC9QvmKWdopKw==",
      "dev": true,
      "license": "MIT",
      "engines": {
        "node": ">=6.0.0"
      }
    },
    "node_modules/@jridgewell/sourcemap-codec": {
      "version": "1.5.5",
      "resolved": "https://registry.npmjs.org/@jridgewell/sourcemap-codec/-/sourcemap-codec-1.5.5.tgz",
      "integrity": "sha512-cYQ9310grqxueWbl+WuIUIaiUaDcj7WOq5fVhEljNVgRfOUhY9fy2zTvfoqWsnebh8Sl70VScFbICvJnLKB0Og==",
      "dev": true,
      "license": "MIT"
    },
    "node_modules/@jridgewell/trace-mapping": {
      "version": "0.3.31",
      "resolved": "https://registry.npmjs.org/@jridgewell/trace-mapping/-/trace-mapping-0.3.31.tgz",
      "integrity": "sha512-zzNR+SdQSDJzc8joaeP8QQoCQr8NuYx2dIIytl1QeBEZHJ9uW6hebsrYgbz8hJwUQao3TWCMtmfV8Nu1twOLAw==",
      "dev": true,
      "license": "MIT",
      "dependencies": {
        "@jridgewell/resolve-uri": "^3.1.0",
        "@jridgewell/sourcemap-codec": "^1.4.14"
      }
    },
    "node_modules/@libsql/client": {
      "version": "0.17.3",
      "resolved": "https://registry.npmjs.org/@libsql/client/-/client-0.17.3.tgz",
      "integrity": "sha512-HXk9wiAoJbKFbyBH4O+aEhN6ir5ERXuXvwE5OD2eR4/5RUa3Pw/8L9zrnVdU+iNJitRvisPWaIwmhkO3bH7giA==",
      "license": "MIT",
      "dependencies": {
        "@libsql/core": "^0.17.3",
        "@libsql/hrana-client": "^0.10.0",
        "js-base64": "^3.7.5",
        "libsql": "^0.5.28",
        "promise-limit": "^2.7.0"
      }
    },
    "node_modules/@libsql/core": {
      "version": "0.17.3",
      "resolved": "https://registry.npmjs.org/@libsql/core/-/core-0.17.3.tgz",
      "integrity": "sha512-2UjK1i7JBkMduJo4WdvvBxMMvVJ31pArBZNONyz/GCJJAH+1UHat2X6vn10S/WpY5fKzIT98WqYFl2vzWRLOfg==",
      "license": "MIT",
      "dependencies": {
        "js-base64": "^3.7.5"
      }
    },
    "node_modules/@libsql/darwin-arm64": {
      "version": "0.5.29",
      "resolved": "https://registry.npmjs.org/@libsql/darwin-arm64/-/darwin-arm64-0.5.29.tgz",
      "integrity": "sha512-K+2RIB1OGFPYQbfay48GakLhqf3ArcbHqPFu7EZiaUcRgFcdw8RoltsMyvbj5ix2fY0HV3Q3Ioa/ByvQdaSM0A==",
      "cpu": [
        "arm64"
      ],
      "license": "MIT",
      "optional": true,
      "os": [
        "darwin"
      ]
    },
    "node_modules/@libsql/darwin-x64": {
      "version": "0.5.29",
      "resolved": "https://registry.npmjs.org/@libsql/darwin-x64/-/darwin-x64-0.5.29.tgz",
      "integrity": "sha512-OtT+KFHsKFy1R5FVadr8FJ2Bb1mghtXTyJkxv0trocq7NuHntSki1eUbxpO5ezJesDvBlqFjnWaYYY516QNLhQ==",
      "cpu": [
        "x64"
      ],
      "license": "MIT",
      "optional": true,
      "os": [
        "darwin"
      ]
    },
    "node_modules/@libsql/hrana-client": {
      "version": "0.10.0",
      "resolved": "https://registry.npmjs.org/@libsql/hrana-client/-/hrana-client-0.10.0.tgz",
      "integrity": "sha512-OoA4EMqRAC7kn7V2P6EQqRcpZf2W+AjsNIyCizBg339Tq/aMC7sRnzs3SklderhmQWAqEzvv8A2vhxVmWpkVvw==",
      "license": "MIT",
      "dependencies": {
        "@libsql/isomorphic-ws": "^0.1.5",
        "js-base64": "^3.7.5"
      }
    },
    "node_modules/@libsql/isomorphic-ws": {
      "version": "0.1.5",
      "resolved": "https://registry.npmjs.org/@libsql/isomorphic-ws/-/isomorphic-ws-0.1.5.tgz",
      "integrity": "sha512-DtLWIH29onUYR00i0GlQ3UdcTRC6EP4u9w/h9LxpUZJWRMARk6dQwZ6Jkd+QdwVpuAOrdxt18v0K2uIYR3fwFg==",
      "license": "MIT",
      "dependencies": {
        "@types/ws": "^8.5.4",
        "ws": "^8.13.0"
      }
    },
    "node_modules/@libsql/linux-arm-gnueabihf": {
      "version": "0.5.29",
      "resolved": "https://registry.npmjs.org/@libsql/linux-arm-gnueabihf/-/linux-arm-gnueabihf-0.5.29.tgz",
      "integrity": "sha512-CD4n4zj7SJTHso4nf5cuMoWoMSS7asn5hHygsDuhRl8jjjCTT3yE+xdUvI4J7zsyb53VO5ISh4cwwOtf6k2UhQ==",
      "cpu": [
        "arm"
      ],
      "license": "MIT",
      "optional": true,
      "os": [
        "linux"
      ]
    },
    "node_modules/@libsql/linux-arm-musleabihf": {
      "version": "0.5.29",
      "resolved": "https://registry.npmjs.org/@libsql/linux-arm-musleabihf/-/linux-arm-musleabihf-0.5.29.tgz",
      "integrity": "sha512-2Z9qBVpEJV7OeflzIR3+l5yAd4uTOLxklScYTwpZnkm2vDSGlC1PRlueLaufc4EFITkLKXK2MWBpexuNJfMVcg==",
      "cpu": [
        "arm"
      ],
      "license": "MIT",
      "optional": true,
      "os": [
        "linux"
      ]
    },
    "node_modules/@libsql/linux-arm64-gnu": {
      "version": "0.5.29",
      "resolved": "https://registry.npmjs.org/@libsql/linux-arm64-gnu/-/linux-arm64-gnu-0.5.29.tgz",
      "integrity": "sha512-gURBqaiXIGGwFNEaUj8Ldk7Hps4STtG+31aEidCk5evMMdtsdfL3HPCpvys+ZF/tkOs2MWlRWoSq7SOuCE9k3w==",
      "cpu": [
        "arm64"
      ],
      "license": "MIT",
      "optional": true,
      "os": [
        "linux"
      ]
    },
    "node_modules/@libsql/linux-arm64-musl": {
      "version": "0.5.29",
      "resolved": "https://registry.npmjs.org/@libsql/linux-arm64-musl/-/linux-arm64-musl-0.5.29.tgz",
      "integrity": "sha512-fwgYZ0H8mUkyVqXZHF3mT/92iIh1N94Owi/f66cPVNsk9BdGKq5gVpoKO+7UxaNzuEH1roJp2QEwsCZMvBLpqg==",
      "cpu": [
        "arm64"
      ],
      "license": "MIT",
      "optional": true,
      "os": [
        "linux"
      ]
    },
    "node_modules/@libsql/linux-x64-gnu": {
      "version": "0.5.29",
      "resolved": "https://registry.npmjs.org/@libsql/linux-x64-gnu/-/linux-x64-gnu-0.5.29.tgz",
      "integrity": "sha512-y14V0vY0nmMC6G0pHeJcEarcnGU2H6cm21ZceRkacWHvQAEhAG0latQkCtoS2njFOXiYIg+JYPfAoWKbi82rkg==",
      "cpu": [
        "x64"
      ],
      "license": "MIT",
      "optional": true,
      "os": [
        "linux"
      ]
    },
    "node_modules/@libsql/linux-x64-musl": {
      "version": "0.5.29",
      "resolved": "https://registry.npmjs.org/@libsql/linux-x64-musl/-/linux-x64-musl-0.5.29.tgz",
      "integrity": "sha512-gquqwA/39tH4pFl+J9n3SOMSymjX+6kZ3kWgY3b94nXFTwac9bnFNMffIomgvlFaC4ArVqMnOZD3nuJ3H3VO1w==",
      "cpu": [
        "x64"
      ],
      "license": "MIT",
      "optional": true,
      "os": [
        "linux"
      ]
    },
    "node_modules/@libsql/win32-x64-msvc": {
      "version": "0.5.29",
      "resolved": "https://registry.npmjs.org/@libsql/win32-x64-msvc/-/win32-x64-msvc-0.5.29.tgz",
      "integrity": "sha512-4/0CvEdhi6+KjMxMaVbFM2n2Z44escBRoEYpR+gZg64DdetzGnYm8mcNLcoySaDJZNaBd6wz5DNdgRmcI4hXcg==",
      "cpu": [
        "x64"
      ],
      "license": "MIT",
      "optional": true,
      "os": [
        "win32"
      ]
    },
    "node_modules/@napi-rs/wasm-runtime": {
      "version": "1.1.6",
      "resolved": "https://registry.npmjs.org/@napi-rs/wasm-runtime/-/wasm-runtime-1.1.6.tgz",
      "integrity": "sha512-ZLv/JdUfkvOy9eCnnBaGfiO+XimbjebAeO+MRQqD/B+FR1tnRN0tpKSJHRbE8sFfS6aqsXZ67TQjfwfsxULVbg==",
      "dev": true,
      "license": "MIT",
      "optional": true,
      "dependencies": {
        "@tybys/wasm-util": "^0.10.3"
      },
      "funding": {
        "type": "github",
        "url": "https://github.com/sponsors/Brooooooklyn"
      },
      "peerDependencies": {
        "@emnapi/core": "^1.7.1",
        "@emnapi/runtime": "^1.7.1"
      }
    },
    "node_modules/@neon-rs/load": {
      "version": "0.0.4",
      "resolved": "https://registry.npmjs.org/@neon-rs/load/-/load-0.0.4.tgz",
      "integrity": "sha512-kTPhdZyTQxB+2wpiRcFWrDcejc4JI6tkPuS7UZCG4l6Zvc5kU/gGQ/ozvHTh1XR5tS+UlfAfGuPajjzQjCiHCw==",
      "license": "MIT"
    },
    "node_modules/@noble/hashes": {
      "version": "1.8.0",
      "resolved": "https://registry.npmjs.org/@noble/hashes/-/hashes-1.8.0.tgz",
      "integrity": "sha512-jCs9ldd7NwzpgXDIf6P3+NrHh9/sD6CQdxHyjQI+h/6rDNo88ypBxxz45UDuZHz9r3tNz7N/VInSVoVdtXEI4A==",
      "dev": true,
      "license": "MIT",
      "engines": {
        "node": "^14.21.3 || >=16"
      },
      "funding": {
        "url": "https://paulmillr.com/funding/"
      }
    },
    "node_modules/@oxc-project/types": {
      "version": "0.137.0",
      "resolved": "https://registry.npmjs.org/@oxc-project/types/-/types-0.137.0.tgz",
      "integrity": "sha512-WT+Gb24i8hmvo85AIv2oEYouEXkRlKAlT9WaCa3TfLgNCN+GhrJOGZuIlMouAh38Qe4QOx26eUOVsq70qXrywA==",
      "dev": true,
      "license": "MIT",
      "funding": {
        "url": "https://github.com/sponsors/Boshen"
      }
    },
    "node_modules/@paralleldrive/cuid2": {
      "version": "2.3.1",
      "resolved": "https://registry.npmjs.org/@paralleldrive/cuid2/-/cuid2-2.3.1.tgz",
      "integrity": "sha512-XO7cAxhnTZl0Yggq6jOgjiOHhbgcO4NqFqwSmQpjK3b6TEE6Uj/jfSk6wzYyemh3+I0sHirKSetjQwn5cZktFw==",
      "dev": true,
      "license": "MIT",
      "dependencies": {
        "@noble/hashes": "^1.1.5"
      }
    },
    "node_modules/@remix-run/router": {
      "version": "1.23.3",
      "resolved": "https://registry.npmjs.org/@remix-run/router/-/router-1.23.3.tgz",
      "integrity": "sha512-4An71tdz9X8+3sI4Qqqd2LWd9vS39J7sqd9EU4Scw7TJE/qB10Flv/UuqbPVgfQV9XoK8Np6jNquZitnZq5i+Q==",
      "license": "MIT",
      "engines": {
        "node": ">=14.0.0"
      }
    },
    "node_modules/@rolldown/binding-android-arm64": {
      "version": "1.1.3",
      "resolved": "https://registry.npmjs.org/@rolldown/binding-android-arm64/-/binding-android-arm64-1.1.3.tgz",
      "integrity": "sha512-DT6Z3PhvioeHMvxo+xHc3KtqggrI7CCTXCmC2h/5zUlp5jVitv7XEy+9q5/7v8IolhlioawpMo8Kg0EEBy7J0g==",
      "cpu": [
        "arm64"
      ],
      "dev": true,
      "license": "MIT",
      "optional": true,
      "os": [
        "android"
      ],
      "engines": {
        "node": "^20.19.0 || >=22.12.0"
      }
    },
    "node_modules/@rolldown/binding-darwin-arm64": {
      "version": "1.1.3",
      "resolved": "https://registry.npmjs.org/@rolldown/binding-darwin-arm64/-/binding-darwin-arm64-1.1.3.tgz",
      "integrity": "sha512-0NwgwsjM7LrsuVnXMK3koTpagBNOhloc/BNjKqZjv4V5zI5r13qx69uVhRx+o5Z0yy4Hzq+lpy7TAgUG/ocvrw==",
      "cpu": [
        "arm64"
      ],
      "dev": true,
      "license": "MIT",
      "optional": true,
      "os": [
        "darwin"
      ],
      "engines": {
        "node": "^20.19.0 || >=22.12.0"
      }
    },
    "node_modules/@rolldown/binding-darwin-x64": {
      "version": "1.1.3",
      "resolved": "https://registry.npmjs.org/@rolldown/binding-darwin-x64/-/binding-darwin-x64-1.1.3.tgz",
      "integrity": "sha512-YtiBp4disu6V560loT6PjMdiRaWmVvDNrUunAalbiFx2ggeJwxdAsgZMcoGP17uyAsTwAj5V1niksxlHnVQ1Sw==",
      "cpu": [
        "x64"
      ],
      "dev": true,
      "license": "MIT",
      "optional": true,
      "os": [
        "darwin"
      ],
      "engines": {
        "node": "^20.19.0 || >=22.12.0"
      }
    },
    "node_modules/@rolldown/binding-freebsd-x64": {
      "version": "1.1.3",
      "resolved": "https://registry.npmjs.org/@rolldown/binding-freebsd-x64/-/binding-freebsd-x64-1.1.3.tgz",
      "integrity": "sha512-yD3EkEdXk2LypPxnf/kSZHirarsI8gcPzc62SukhR9VJTyvV+F9Q/GxWNuCojc7sXyuVC4DxRGhdDK4X8VSsbw==",
      "cpu": [
        "x64"
      ],
      "dev": true,
      "license": "MIT",
      "optional": true,
      "os": [
        "freebsd"
      ],
      "engines": {
        "node": "^20.19.0 || >=22.12.0"
      }
    },
    "node_modules/@rolldown/binding-linux-arm-gnueabihf": {
      "version": "1.1.3",
      "resolved": "https://registry.npmjs.org/@rolldown/binding-linux-arm-gnueabihf/-/binding-linux-arm-gnueabihf-1.1.3.tgz",
      "integrity": "sha512-c+8vieQbsD7HNAHKIA34w0GJ9FedFFuJGD+7E6vz7Q3uqAIugL5p45fhlsj4UaAsHpcmlqugBWMhA0/j7o0sIg==",
      "cpu": [
        "arm"
      ],
      "dev": true,
      "license": "MIT",
      "optional": true,
      "os": [
        "linux"
      ],
      "engines": {
        "node": "^20.19.0 || >=22.12.0"
      }
    },
    "node_modules/@rolldown/binding-linux-arm64-gnu": {
      "version": "1.1.3",
      "resolved": "https://registry.npmjs.org/@rolldown/binding-linux-arm64-gnu/-/binding-linux-arm64-gnu-1.1.3.tgz",
      "integrity": "sha512-50jD0uUwLvur7Zz9LHz17kaAdTPjn5wN93hEgjvmYFRZwiR7ZJYovTd5ipyWJDAnXKvZ+wgc+/Ika6dwSF5OcA==",
      "cpu": [
        "arm64"
      ],
      "dev": true,
      "license": "MIT",
      "optional": true,
      "os": [
        "linux"
      ],
      "engines": {
        "node": "^20.19.0 || >=22.12.0"
      }
    },
    "node_modules/@rolldown/binding-linux-arm64-musl": {
      "version": "1.1.3",
      "resolved": "https://registry.npmjs.org/@rolldown/binding-linux-arm64-musl/-/binding-linux-arm64-musl-1.1.3.tgz",
      "integrity": "sha512-BO9+oPL8K9poZJBfYPsXNtYjPE5uM3qeehT3aFcW4LITOl+iSqhp0abzjR2nWBUNjIZeKXjAEWBZ64WjNoHd6w==",
      "cpu": [
        "arm64"
      ],
      "dev": true,
      "license": "MIT",
      "optional": true,
      "os": [
        "linux"
      ],
      "engines": {
        "node": "^20.19.0 || >=22.12.0"
      }
    },
    "node_modules/@rolldown/binding-linux-ppc64-gnu": {
      "version": "1.1.3",
      "resolved": "https://registry.npmjs.org/@rolldown/binding-linux-ppc64-gnu/-/binding-linux-ppc64-gnu-1.1.3.tgz",
      "integrity": "sha512-f3VpLB1vQ0Eo6ecr/6cekLnvYMFF4YBFoVGkfkvPLq1bAkbAwHYQPZKoAmG6OJyTcxxoC+AvezGx/S1obNC0Mw==",
      "cpu": [
        "ppc64"
      ],
      "dev": true,
      "license": "MIT",
      "optional": true,
      "os": [
        "linux"
      ],
      "engines": {
        "node": "^20.19.0 || >=22.12.0"
      }
    },
    "node_modules/@rolldown/binding-linux-s390x-gnu": {
      "version": "1.1.3",
      "resolved": "https://registry.npmjs.org/@rolldown/binding-linux-s390x-gnu/-/binding-linux-s390x-gnu-1.1.3.tgz",
      "integrity": "sha512-AmurZ26Pqx/RI9N1gzEOCklkKXl927yjfXWUUS0O7Puh8ARM/Ob8qfrD3qnWksScdw6cSrW5PSHE9DyLu7+PtA==",
      "cpu": [
        "s390x"
      ],
      "dev": true,
      "license": "MIT",
      "optional": true,
      "os": [
        "linux"
      ],
      "engines": {
        "node": "^20.19.0 || >=22.12.0"
      }
    },
    "node_modules/@rolldown/binding-linux-x64-gnu": {
      "version": "1.1.3",
      "resolved": "https://registry.npmjs.org/@rolldown/binding-linux-x64-gnu/-/binding-linux-x64-gnu-1.1.3.tgz",
      "integrity": "sha512-JJpqs8bRGITDOdbkNKnlojzBabbOHrqjSvDr0IVsZObE1lBcPjxItUEY9eWIDbxaJ3cGrXPWGfGkIxFijg/URg==",
      "cpu": [
        "x64"
      ],
      "dev": true,
      "license": "MIT",
      "optional": true,
      "os": [
        "linux"
      ],
      "engines": {
        "node": "^20.19.0 || >=22.12.0"
      }
    },
    "node_modules/@rolldown/binding-linux-x64-musl": {
      "version": "1.1.3",
      "resolved": "https://registry.npmjs.org/@rolldown/binding-linux-x64-musl/-/binding-linux-x64-musl-1.1.3.tgz",
      "integrity": "sha512-rSJcdjPxzA/by/6/rYs+v+bXU7UjvnbUWz8MJb6kh6+knqB1dCrtHg0uu7C/4haqJvqdkYHQ5IGn+tCH9GLW/g==",
      "cpu": [
        "x64"
      ],
      "dev": true,
      "license": "MIT",
      "optional": true,
      "os": [
        "linux"
      ],
      "engines": {
        "node": "^20.19.0 || >=22.12.0"
      }
    },
    "node_modules/@rolldown/binding-openharmony-arm64": {
      "version": "1.1.3",
      "resolved": "https://registry.npmjs.org/@rolldown/binding-openharmony-arm64/-/binding-openharmony-arm64-1.1.3.tgz",
      "integrity": "sha512-hQ3/PYkDJICgevvyNcVrihVeqq7k1Pp3VZ9lY+dauAYUJKO+auqApvANhvR1An9BhmqYKvW2Mu1F9u4DXSMLxQ==",
      "cpu": [
        "arm64"
      ],
      "dev": true,
      "license": "MIT",
      "optional": true,
      "os": [
        "openharmony"
      ],
      "engines": {
        "node": "^20.19.0 || >=22.12.0"
      }
    },
    "node_modules/@rolldown/binding-wasm32-wasi": {
      "version": "1.1.3",
      "resolved": "https://registry.npmjs.org/@rolldown/binding-wasm32-wasi/-/binding-wasm32-wasi-1.1.3.tgz",
      "integrity": "sha512-Elcv/BtML9lXrV6JuKITc/grN2kYV9gjsQpW8Jfw4ioK0TOkjBjye0nnyqQNy9STNaI20lXNaQBRrD5gSgR0Yg==",
      "cpu": [
        "wasm32"
      ],
      "dev": true,
      "license": "MIT",
      "optional": true,
      "dependencies": {
        "@emnapi/core": "1.11.1",
        "@emnapi/runtime": "1.11.1",
        "@napi-rs/wasm-runtime": "^1.1.6"
      },
      "engines": {
        "node": "^20.19.0 || >=22.12.0"
      }
    },
    "node_modules/@rolldown/binding-win32-arm64-msvc": {
      "version": "1.1.3",
      "resolved": "https://registry.npmjs.org/@rolldown/binding-win32-arm64-msvc/-/binding-win32-arm64-msvc-1.1.3.tgz",
      "integrity": "sha512-2DrEfhluH9yhiaFApmsjsjwrSYbNcY1oFTzYSP1a535jDbV98zCFanA/96TBUd0iDFcxGmw9QRExwGCXz3U+/g==",
      "cpu": [
        "arm64"
      ],
      "dev": true,
      "license": "MIT",
      "optional": true,
      "os": [
        "win32"
      ],
      "engines": {
        "node": "^20.19.0 || >=22.12.0"
      }
    },
    "node_modules/@rolldown/binding-win32-x64-msvc": {
      "version": "1.1.3",
      "resolved": "https://registry.npmjs.org/@rolldown/binding-win32-x64-msvc/-/binding-win32-x64-msvc-1.1.3.tgz",
      "integrity": "sha512-OL4OMk7UPXOeVGGd3qo5zJyPIljf4AFgk5QAkPPS+OoLuOOozhuaQGC18MxVTnw/06q93gShAJzlwnSCY9YtqA==",
      "cpu": [
        "x64"
      ],
      "dev": true,
      "license": "MIT",
      "optional": true,
      "os": [
        "win32"
      ],
      "engines": {
        "node": "^20.19.0 || >=22.12.0"
      }
    },
    "node_modules/@rolldown/pluginutils": {
      "version": "1.0.1",
      "resolved": "https://registry.npmjs.org/@rolldown/pluginutils/-/pluginutils-1.0.1.tgz",
      "integrity": "sha512-2j9bGt5Jh8hj+vPtgzPtl72j0yRxHAyumoo6TNfAjsLB04UtpSvPbPcDcBMxz7n+9CYB0c1GxQFxYRg2jimqGw==",
      "dev": true,
      "license": "MIT"
    },
    "node_modules/@standard-schema/spec": {
      "version": "1.1.0",
      "resolved": "https://registry.npmjs.org/@standard-schema/spec/-/spec-1.1.0.tgz",
      "integrity": "sha512-l2aFy5jALhniG5HgqrD6jXLi/rUWrKvqN/qJx6yoJsgKhblVd+iqqU4RCXavm/jPityDo5TCvKMnpjKnOriy0w==",
      "dev": true,
      "license": "MIT"
    },
    "node_modules/@tybys/wasm-util": {
      "version": "0.10.3",
      "resolved": "https://registry.npmjs.org/@tybys/wasm-util/-/wasm-util-0.10.3.tgz",
      "integrity": "sha512-F3fo1MYrRJYL3zER0OUOmkutjr1Vp23m7OsSgp7nq4SP6OqX6C/56XFIPAl5bt3zaBRjmW7SGz3u/6LwFpYcOg==",
      "dev": true,
      "license": "MIT",
      "optional": true,
      "dependencies": {
        "tslib": "^2.4.0"
      }
    },
    "node_modules/@types/bcryptjs": {
      "version": "2.4.6",
      "resolved": "https://registry.npmjs.org/@types/bcryptjs/-/bcryptjs-2.4.6.tgz",
      "integrity": "sha512-9xlo6R2qDs5uixm0bcIqCeMCE6HiQsIyel9KQySStiyqNl2tnj2mP3DX1Nf56MD6KMenNNlBBsy3LJ7gUEQPXQ==",
      "dev": true,
      "license": "MIT"
    },
    "node_modules/@types/chai": {
      "version": "5.2.3",
      "resolved": "https://registry.npmjs.org/@types/chai/-/chai-5.2.3.tgz",
      "integrity": "sha512-Mw558oeA9fFbv65/y4mHtXDs9bPnFMZAL/jxdPFUpOHHIXX91mcgEHbS5Lahr+pwZFR8A7GQleRWeI6cGFC2UA==",
      "dev": true,
      "license": "MIT",
      "dependencies": {
        "@types/deep-eql": "*",
        "assertion-error": "^2.0.1"
      }
    },
    "node_modules/@types/deep-eql": {
      "version": "4.0.2",
      "resolved": "https://registry.npmjs.org/@types/deep-eql/-/deep-eql-4.0.2.tgz",
      "integrity": "sha512-c9h9dVVMigMPc4bwTvC5dxqtqJZwQPePsWjPlpSOnojbor6pGqdk541lfA7AqFQr5pB1BRdq0juY9db81BwyFw==",
      "dev": true,
      "license": "MIT"
    },
    "node_modules/@types/estree": {
      "version": "1.0.9",
      "resolved": "https://registry.npmjs.org/@types/estree/-/estree-1.0.9.tgz",
      "integrity": "sha512-GhdPgy1el4/ImP05X05Uw4cw2/M93BCUmnEvWZNStlCzEKME4Fkk+YpoA5OiHNQmoS7Cafb8Xa3Pya8m1Qrzeg==",
      "dev": true,
      "license": "MIT"
    },
    "node_modules/@types/node": {
      "version": "25.9.3",
      "resolved": "https://registry.npmjs.org/@types/node/-/node-25.9.3.tgz",
      "integrity": "sha512-603BddQMv3pUcr4U2dhujk83N2tTDVr/34wII2B6bJy6g+8WD6yUb11jszNs0gdi4PesVWl7ABt8nYMVpnLUcg==",
      "license": "MIT",
      "dependencies": {
        "undici-types": ">=7.24.0 <7.24.7"
      }
    },
    "node_modules/@types/react": {
      "version": "19.2.17",
      "resolved": "https://registry.npmjs.org/@types/react/-/react-19.2.17.tgz",
      "integrity": "sha512-MXfmqaVPEVgkBT/aY0aGCkRWWtByiYQXo3xdQ8r5RzuFrPiRn8Gar2tQdXSUQ2GKV3bkXckek89V8wQBY2Q/Aw==",
      "dev": true,
      "license": "MIT",
      "dependencies": {
        "csstype": "^3.2.2"
      }
    },
    "node_modules/@types/react-dom": {
      "version": "19.2.3",
      "resolved": "https://registry.npmjs.org/@types/react-dom/-/react-dom-19.2.3.tgz",
      "integrity": "sha512-jp2L/eY6fn+KgVVQAOqYItbF0VY/YApe5Mz2F0aykSO8gx31bYCZyvSeYxCHKvzHG5eZjc+zyaS5BrBWya2+kQ==",
      "dev": true,
      "license": "MIT",
      "peerDependencies": {
        "@types/react": "^19.2.0"
      }
    },
    "node_modules/@types/ws": {
      "version": "8.18.1",
      "resolved": "https://registry.npmjs.org/@types/ws/-/ws-8.18.1.tgz",
      "integrity": "sha512-ThVF6DCVhA8kUGy+aazFQ4kXQ7E1Ty7A3ypFOe0IcJV8O/M511G99AW24irKrW56Wt44yG9+ij8FaqoBGkuBXg==",
      "license": "MIT",
      "dependencies": {
        "@types/node": "*"
      }
    },
    "node_modules/@vitejs/plugin-react": {
      "version": "6.0.3",
      "resolved": "https://registry.npmjs.org/@vitejs/plugin-react/-/plugin-react-6.0.3.tgz",
      "integrity": "sha512-vmFvco5/QuC2f9Oj+wTk0+9XeDFkHxSamwZKYc7MxYwKICfvUvlMhqKI0VuICPltGqh1neqBKDvO4kes1ya8vg==",
      "dev": true,
      "license": "MIT",
      "dependencies": {
        "@rolldown/pluginutils": "^1.0.1"
      },
      "engines": {
        "node": "^20.19.0 || >=22.12.0"
      },
      "peerDependencies": {
        "@rolldown/plugin-babel": "^0.1.7 || ^0.2.0",
        "babel-plugin-react-compiler": "^1.0.0",
        "vite": "^8.0.0"
      },
      "peerDependenciesMeta": {
        "@rolldown/plugin-babel": {
          "optional": true
        },
        "babel-plugin-react-compiler": {
          "optional": true
        }
      }
    },
    "node_modules/@vitest/coverage-v8": {
      "version": "4.1.9",
      "resolved": "https://registry.npmjs.org/@vitest/coverage-v8/-/coverage-v8-4.1.9.tgz",
      "integrity": "sha512-G9/lgqibheLVBDRuya45EbsEXTYcWoSG+TLg7i2axuzx0Eq62eXn+aWXyaVdV5vKvFSWd6ywcX8hA7la9Pvu8g==",
      "dev": true,
      "license": "MIT",
      "dependencies": {
        "@bcoe/v8-coverage": "^1.0.2",
        "@vitest/utils": "4.1.9",
        "ast-v8-to-istanbul": "^1.0.0",
        "istanbul-lib-coverage": "^3.2.2",
        "istanbul-lib-report": "^3.0.1",
        "istanbul-reports": "^3.2.0",
        "magicast": "^0.5.2",
        "obug": "^2.1.1",
        "std-env": "^4.0.0-rc.1",
        "tinyrainbow": "^3.1.0"
      },
      "funding": {
        "url": "https://opencollective.com/vitest"
      },
      "peerDependencies": {
        "@vitest/browser": "4.1.9",
        "vitest": "4.1.9"
      },
      "peerDependenciesMeta": {
        "@vitest/browser": {
          "optional": true
        }
      }
    },
    "node_modules/@vitest/expect": {
      "version": "4.1.9",
      "resolved": "https://registry.npmjs.org/@vitest/expect/-/expect-4.1.9.tgz",
      "integrity": "sha512-vl/rYsUKcBr3SnQn166+XR5ZQcgMx3DQhFWdfli/cWpLnLUmbxZvyrJZotLFUryib+LtArYMSTJ5RbQ57ZqrlA==",
      "dev": true,
      "license": "MIT",
      "dependencies": {
        "@standard-schema/spec": "^1.1.0",
        "@types/chai": "^5.2.2",
        "@vitest/spy": "4.1.9",
        "@vitest/utils": "4.1.9",
        "chai": "^6.2.2",
        "tinyrainbow": "^3.1.0"
      },
      "funding": {
        "url": "https://opencollective.com/vitest"
      }
    },
    "node_modules/@vitest/mocker": {
      "version": "4.1.9",
      "resolved": "https://registry.npmjs.org/@vitest/mocker/-/mocker-4.1.9.tgz",
      "integrity": "sha512-EVkXzBjrPGM+cK8/ANWgBrkUCfJfb38/EfTSO8h7pWvKkyPkpWxvR7BkD2MyItMF62C97zAEoqdpUixwR/e+Rw==",
      "dev": true,
      "license": "MIT",
      "dependencies": {
        "@vitest/spy": "4.1.9",
        "estree-walker": "^3.0.3",
        "magic-string": "^0.30.21"
      },
      "funding": {
        "url": "https://opencollective.com/vitest"
      },
      "peerDependencies": {
        "msw": "^2.4.9",
        "vite": "^6.0.0 || ^7.0.0 || ^8.0.0"
      },
      "peerDependenciesMeta": {
        "msw": {
          "optional": true
        },
        "vite": {
          "optional": true
        }
      }
    },
    "node_modules/@vitest/pretty-format": {
      "version": "4.1.9",
      "resolved": "https://registry.npmjs.org/@vitest/pretty-format/-/pretty-format-4.1.9.tgz",
      "integrity": "sha512-s0iufns3iIFitdgm+YR7g1whCAaGtXz459VS9/PqyKDEEFgYIhsHOQmXgIgDuYCt7DeQmiZT0Qe2OA2p4ZPu5A==",
      "dev": true,
      "license": "MIT",
      "dependencies": {
        "tinyrainbow": "^3.1.0"
      },
      "funding": {
        "url": "https://opencollective.com/vitest"
      }
    },
    "node_modules/@vitest/runner": {
      "version": "4.1.9",
      "resolved": "https://registry.npmjs.org/@vitest/runner/-/runner-4.1.9.tgz",
      "integrity": "sha512-KXLMDtc7oe70+3mJfGrPUWPesswH+3sTxAMAMl8DG7I8IUQT4XW718dY5ID3vPUcmlu27CcKfY4P3h3I29SLJg==",
      "dev": true,
      "license": "MIT",
      "dependencies": {
        "@vitest/utils": "4.1.9",
        "pathe": "^2.0.3"
      },
      "funding": {
        "url": "https://opencollective.com/vitest"
      }
    },
    "node_modules/@vitest/snapshot": {
      "version": "4.1.9",
      "resolved": "https://registry.npmjs.org/@vitest/snapshot/-/snapshot-4.1.9.tgz",
      "integrity": "sha512-Jc7RKGNBo8Z28WYIm0Niej4xdSPByRf6mU58VpHQkd6Zh05rlnA+twjbK5HyeIGHxrzsc3mJgS43uM0CZKzaIA==",
      "dev": true,
      "license": "MIT",
      "dependencies": {
        "@vitest/pretty-format": "4.1.9",
        "@vitest/utils": "4.1.9",
        "magic-string": "^0.30.21",
        "pathe": "^2.0.3"
      },
      "funding": {
        "url": "https://opencollective.com/vitest"
      }
    },
    "node_modules/@vitest/spy": {
      "version": "4.1.9",
      "resolved": "https://registry.npmjs.org/@vitest/spy/-/spy-4.1.9.tgz",
      "integrity": "sha512-fHpsS6mIi+PiEW+vcRVOMkX1oSaPKne3VOclSFICPcGOmfKgXPU5iAah+wcNcj2xPrCCmfq99IDGf+EojhhvhA==",
      "dev": true,
      "license": "MIT",
      "funding": {
        "url": "https://opencollective.com/vitest"
      }
    },
    "node_modules/@vitest/utils": {
      "version": "4.1.9",
      "resolved": "https://registry.npmjs.org/@vitest/utils/-/utils-4.1.9.tgz",
      "integrity": "sha512-A51o8ymO5PpqlWNnBP9ZHPXDIpuMtTLlGSjN7la4US+LJzoUMyhwjA5QXlm39JexgwHKW4Xjs8Z2d3dLCXOeuA==",
      "dev": true,
      "license": "MIT",
      "dependencies": {
        "@vitest/pretty-format": "4.1.9",
        "convert-source-map": "^2.0.0",
        "tinyrainbow": "^3.1.0"
      },
      "funding": {
        "url": "https://opencollective.com/vitest"
      }
    },
    "node_modules/accepts": {
      "version": "1.3.8",
      "resolved": "https://registry.npmjs.org/accepts/-/accepts-1.3.8.tgz",
      "integrity": "sha512-PYAthTa2m2VKxuvSD3DPC/Gy+U+sOA1LAuT8mkmRuvw+NACSaeXEQ+NHcVF7rONl6qcaxV3Uuemwawk+7+SJLw==",
      "dev": true,
      "license": "MIT",
      "dependencies": {
        "mime-types": "~2.1.34",
        "negotiator": "0.6.3"
      },
      "engines": {
        "node": ">= 0.6"
      }
    },
    "node_modules/accepts/node_modules/negotiator": {
      "version": "0.6.3",
      "resolved": "https://registry.npmjs.org/negotiator/-/negotiator-0.6.3.tgz",
      "integrity": "sha512-+EUsqGPLsM+j/zdChZjsnX51g4XrHFOIXwfnCVPGlQk/k5giakcKsuxCObBRu6DSm9opw/O6slWbJdghQM4bBg==",
      "dev": true,
      "license": "MIT",
      "engines": {
        "node": ">= 0.6"
      }
    },
    "node_modules/ansi-regex": {
      "version": "6.2.2",
      "resolved": "https://registry.npmjs.org/ansi-regex/-/ansi-regex-6.2.2.tgz",
      "integrity": "sha512-Bq3SmSpyFHaWjPk8If9yc6svM8c56dB5BAtW4Qbw5jHTwwXXcTLoRMkpDJp6VL0XzlWaCHTXrkFURMYmD0sLqg==",
      "dev": true,
      "license": "MIT",
      "engines": {
        "node": ">=12"
      },
      "funding": {
        "url": "https://github.com/chalk/ansi-regex?sponsor=1"
      }
    },
    "node_modules/ansi-styles": {
      "version": "6.2.3",
      "resolved": "https://registry.npmjs.org/ansi-styles/-/ansi-styles-6.2.3.tgz",
      "integrity": "sha512-4Dj6M28JB+oAH8kFkTLUo+a2jwOFkuqb3yucU0CANcRRUbxS0cP0nZYCGjcc3BNXwRIsUVmDGgzawme7zvJHvg==",
      "dev": true,
      "license": "MIT",
      "engines": {
        "node": ">=12"
      },
      "funding": {
        "url": "https://github.com/chalk/ansi-styles?sponsor=1"
      }
    },
    "node_modules/array-flatten": {
      "version": "1.1.1",
      "resolved": "https://registry.npmjs.org/array-flatten/-/array-flatten-1.1.1.tgz",
      "integrity": "sha512-PCVAQswWemu6UdxsDFFX/+gVeYqKAod3D3UVm91jHwynguOwAvYPhx8nNlM++NqRcK6CxxpUafjmhIdKiHibqg==",
      "dev": true,
      "license": "MIT"
    },
    "node_modules/asap": {
      "version": "2.0.6",
      "resolved": "https://registry.npmjs.org/asap/-/asap-2.0.6.tgz",
      "integrity": "sha512-BSHWgDSAiKs50o2Re8ppvp3seVHXSRM44cdSsT9FfNEUUZLOGWVCsiWaRPWM1Znn+mqZ1OfVZ3z3DWEzSp7hRA==",
      "dev": true,
      "license": "MIT"
    },
    "node_modules/assertion-error": {
      "version": "2.0.1",
      "resolved": "https://registry.npmjs.org/assertion-error/-/assertion-error-2.0.1.tgz",
      "integrity": "sha512-Izi8RQcffqCeNVgFigKli1ssklIbpHnCYc6AknXGYoB6grJqyeby7jv12JUQgmTAnIDnbck1uxksT4dzN3PWBA==",
      "dev": true,
      "license": "MIT",
      "engines": {
        "node": ">=12"
      }
    },
    "node_modules/ast-v8-to-istanbul": {
      "version": "1.0.4",
      "resolved": "https://registry.npmjs.org/ast-v8-to-istanbul/-/ast-v8-to-istanbul-1.0.4.tgz",
      "integrity": "sha512-0bC0/4bTSrnwdhU3IsZDwEdojvuPrSg59OYZfKsLRtJZ0u8VBx9DebfqqG8bRdCC0I7vjgxmPi41P0lpkhJHtA==",
      "dev": true,
      "license": "MIT",
      "dependencies": {
        "@jridgewell/trace-mapping": "^0.3.31",
        "estree-walker": "^3.0.3",
        "js-tokens": "^10.0.0"
      }
    },
    "node_modules/ast-v8-to-istanbul/node_modules/js-tokens": {
      "version": "10.0.0",
      "resolved": "https://registry.npmjs.org/js-tokens/-/js-tokens-10.0.0.tgz",
      "integrity": "sha512-lM/UBzQmfJRo9ABXbPWemivdCW8V2G8FHaHdypQaIy523snUjog0W71ayWXTjiR+ixeMyVHN2XcpnTd/liPg/Q==",
      "dev": true,
      "license": "MIT"
    },
    "node_modules/asynckit": {
      "version": "0.4.0",
      "resolved": "https://registry.npmjs.org/asynckit/-/asynckit-0.4.0.tgz",
      "integrity": "sha512-Oei9OH4tRh0YqU3GxhX79dM/mwVgvbZJaSNaRk+bshkj0S5cfHcgYakreBjrHwatXKbz+IoIdYLxrKim2MjW0Q==",
      "dev": true,
      "license": "MIT"
    },
    "node_modules/bcryptjs": {
      "version": "3.0.3",
      "resolved": "https://registry.npmjs.org/bcryptjs/-/bcryptjs-3.0.3.tgz",
      "integrity": "sha512-GlF5wPWnSa/X5LKM1o0wz0suXIINz1iHRLvTS+sLyi7XPbe5ycmYI3DlZqVGZZtDgl4DmasFg7gOB3JYbphV5g==",
      "license": "BSD-3-Clause",
      "bin": {
        "bcrypt": "bin/bcrypt"
      }
    },
    "node_modules/body-parser": {
      "version": "1.20.5",
      "resolved": "https://registry.npmjs.org/body-parser/-/body-parser-1.20.5.tgz",
      "integrity": "sha512-3grm+/2tUOvu2cjJkvsIxrv/wVpfXQW4PsQHYm7yk4vfpu7Ekl6nEsYBoJUL6qDwZUx8wUhQ8tR2qz+ad9c9OA==",
      "dev": true,
      "license": "MIT",
      "dependencies": {
        "bytes": "~3.1.2",
        "content-type": "~1.0.5",
        "debug": "2.6.9",
        "depd": "2.0.0",
        "destroy": "~1.2.0",
        "http-errors": "~2.0.1",
        "iconv-lite": "~0.4.24",
        "on-finished": "~2.4.1",
        "qs": "~6.15.1",
        "raw-body": "~2.5.3",
        "type-is": "~1.6.18",
        "unpipe": "~1.0.0"
      },
      "engines": {
        "node": ">= 0.8",
        "npm": "1.2.8000 || >= 1.4.16"
      }
    },
    "node_modules/body-parser/node_modules/debug": {
      "version": "2.6.9",
      "resolved": "https://registry.npmjs.org/debug/-/debug-2.6.9.tgz",
      "integrity": "sha512-bC7ElrdJaJnPbAP+1EotYvqZsb3ecl5wi6Bfi6BJTUcNowp6cvspg0jXznRTKDjm/E7AdgFBVeAPVMNcKGsHMA==",
      "dev": true,
      "license": "MIT",
      "dependencies": {
        "ms": "2.0.0"
      }
    },
    "node_modules/body-parser/node_modules/ms": {
      "version": "2.0.0",
      "resolved": "https://registry.npmjs.org/ms/-/ms-2.0.0.tgz",
      "integrity": "sha512-Tpp60P6IUJDTuOq/5Z8cdskzJujfwqfOTkrwIwj7IRISpnkJnT6SyJ4PCPnGMoFjC9ddhal5KVIYtAt97ix05A==",
      "dev": true,
      "license": "MIT"
    },
    "node_modules/buffer-equal-constant-time": {
      "version": "1.0.1",
      "resolved": "https://registry.npmjs.org/buffer-equal-constant-time/-/buffer-equal-constant-time-1.0.1.tgz",
      "integrity": "sha512-zRpUiDwd/xk6ADqPMATG8vc9VPrkck7T07OIx0gnjmJAnHnTVXNQG3vfvWNuiZIkwu9KrKdA1iJKfsfTVxE6NA==",
      "dev": true,
      "license": "BSD-3-Clause"
    },
    "node_modules/bytes": {
      "version": "3.1.2",
      "resolved": "https://registry.npmjs.org/bytes/-/bytes-3.1.2.tgz",
      "integrity": "sha512-/Nf7TyzTx6S3yRJObOAV7956r8cr2+Oj8AC5dt8wSP3BQAoeX58NoHyCU8P8zGkNXStjTSi6fzO6F0pBdcYbEg==",
      "dev": true,
      "license": "MIT",
      "engines": {
        "node": ">= 0.8"
      }
    },
    "node_modules/call-bind-apply-helpers": {
      "version": "1.0.2",
      "resolved": "https://registry.npmjs.org/call-bind-apply-helpers/-/call-bind-apply-helpers-1.0.2.tgz",
      "integrity": "sha512-Sp1ablJ0ivDkSzjcaJdxEunN5/XvksFJ2sMBFfq6x0ryhQV/2b/KwFe21cMpmHtPOSij8K99/wSfoEuTObmuMQ==",
      "dev": true,
      "license": "MIT",
      "dependencies": {
        "es-errors": "^1.3.0",
        "function-bind": "^1.1.2"
      },
      "engines": {
        "node": ">= 0.4"
      }
    },
    "node_modules/call-bound": {
      "version": "1.0.4",
      "resolved": "https://registry.npmjs.org/call-bound/-/call-bound-1.0.4.tgz",
      "integrity": "sha512-+ys997U96po4Kx/ABpBCqhA9EuxJaQWDQg7295H4hBphv3IZg0boBKuwYpt4YXp6MZ5AmZQnU/tyMTlRpaSejg==",
      "dev": true,
      "license": "MIT",
      "dependencies": {
        "call-bind-apply-helpers": "^1.0.2",
        "get-intrinsic": "^1.3.0"
      },
      "engines": {
        "node": ">= 0.4"
      },
      "funding": {
        "url": "https://github.com/sponsors/ljharb"
      }
    },
    "node_modules/chai": {
      "version": "6.2.2",
      "resolved": "https://registry.npmjs.org/chai/-/chai-6.2.2.tgz",
      "integrity": "sha512-NUPRluOfOiTKBKvWPtSD4PhFvWCqOi0BGStNWs57X9js7XGTprSmFoz5F0tWhR4WPjNeR9jXqdC7/UpSJTnlRg==",
      "dev": true,
      "license": "MIT",
      "engines": {
        "node": ">=18"
      }
    },
    "node_modules/chalk": {
      "version": "5.6.2",
      "resolved": "https://registry.npmjs.org/chalk/-/chalk-5.6.2.tgz",
      "integrity": "sha512-7NzBL0rN6fMUW+f7A6Io4h40qQlG+xGmtMxfbnH/K7TAtt8JQWVQK+6g0UXKMeVJoyV5EkkNsErQ8pVD3bLHbA==",
      "dev": true,
      "license": "MIT",
      "engines": {
        "node": "^12.17.0 || ^14.13 || >=16.0.0"
      },
      "funding": {
        "url": "https://github.com/chalk/chalk?sponsor=1"
      }
    },
    "node_modules/cliui": {
      "version": "9.0.1",
      "resolved": "https://registry.npmjs.org/cliui/-/cliui-9.0.1.tgz",
      "integrity": "sha512-k7ndgKhwoQveBL+/1tqGJYNz097I7WOvwbmmU2AR5+magtbjPWQTS1C5vzGkBC8Ym8UWRzfKUzUUqFLypY4Q+w==",
      "dev": true,
      "license": "ISC",
      "dependencies": {
        "string-width": "^7.2.0",
        "strip-ansi": "^7.1.0",
        "wrap-ansi": "^9.0.0"
      },
      "engines": {
        "node": ">=20"
      }
    },
    "node_modules/combined-stream": {
      "version": "1.0.8",
      "resolved": "https://registry.npmjs.org/combined-stream/-/combined-stream-1.0.8.tgz",
      "integrity": "sha512-FQN4MRfuJeHf7cBbBMJFXhKSDq+2kAArBlmRBvcvFE5BB1HZKXtSFASDhdlz9zOYwxh8lDdnvmMOe/+5cdoEdg==",
      "dev": true,
      "license": "MIT",
      "dependencies": {
        "delayed-stream": "~1.0.0"
      },
      "engines": {
        "node": ">= 0.8"
      }
    },
    "node_modules/component-emitter": {
      "version": "1.3.1",
      "resolved": "https://registry.npmjs.org/component-emitter/-/component-emitter-1.3.1.tgz",
      "integrity": "sha512-T0+barUSQRTUQASh8bx02dl+DhF54GtIDY13Y3m9oWTklKbb3Wv974meRpeZ3lp1JpLVECWWNHC4vaG2XHXouQ==",
      "dev": true,
      "license": "MIT",
      "funding": {
        "url": "https://github.com/sponsors/sindresorhus"
      }
    },
    "node_modules/concurrently": {
      "version": "10.0.3",
      "resolved": "https://registry.npmjs.org/concurrently/-/concurrently-10.0.3.tgz",
      "integrity": "sha512-hc3LH4UaKWd/bbyDK/IGVa4RB6PtQ3CUYwtrkzqHn+wIG3Hr5fhpRlk0L/gCa8ZE1L/Ufj50Zho69cI5w8SQBA==",
      "dev": true,
      "license": "MIT",
      "dependencies": {
        "chalk": "5.6.2",
        "rxjs": "7.8.2",
        "shell-quote": "1.8.4",
        "supports-color": "10.2.2",
        "tree-kill": "1.2.2",
        "yargs": "18.0.0"
      },
      "bin": {
        "conc": "dist/bin/index.js",
        "concurrently": "dist/bin/index.js"
      },
      "engines": {
        "node": ">=22"
      },
      "funding": {
        "url": "https://github.com/open-cli-tools/concurrently?sponsor=1"
      }
    },
    "node_modules/content-disposition": {
      "version": "0.5.4",
      "resolved": "https://registry.npmjs.org/content-disposition/-/content-disposition-0.5.4.tgz",
      "integrity": "sha512-FveZTNuGw04cxlAiWbzi6zTAL/lhehaWbTtgluJh4/E95DqMwTmha3KZN1aAWA8cFIhHzMZUvLevkw5Rqk+tSQ==",
      "dev": true,
      "license": "MIT",
      "dependencies": {
        "safe-buffer": "5.2.1"
      },
      "engines": {
        "node": ">= 0.6"
      }
    },
    "node_modules/content-type": {
      "version": "1.0.5",
      "resolved": "https://registry.npmjs.org/content-type/-/content-type-1.0.5.tgz",
      "integrity": "sha512-nTjqfcBFEipKdXCv4YDQWCfmcLZKm81ldF0pAopTvyrFGVbcR6P/VAAd5G7N+0tTr8QqiU0tFadD6FK4NtJwOA==",
      "dev": true,
      "license": "MIT",
      "engines": {
        "node": ">= 0.6"
      }
    },
    "node_modules/convert-source-map": {
      "version": "2.0.0",
      "resolved": "https://registry.npmjs.org/convert-source-map/-/convert-source-map-2.0.0.tgz",
      "integrity": "sha512-Kvp459HrV2FEJ1CAsi1Ku+MY3kasH19TFykTz2xWmMeq6bk2NU3XXvfJ+Q61m0xktWwt+1HSYf3JZsTms3aRJg==",
      "dev": true,
      "license": "MIT"
    },
    "node_modules/cookie": {
      "version": "0.7.2",
      "resolved": "https://registry.npmjs.org/cookie/-/cookie-0.7.2.tgz",
      "integrity": "sha512-yki5XnKuf750l50uGTllt6kKILY4nQ1eNIQatoXEByZ5dWgnKqbnqmTrBE5B4N7lrMJKQ2ytWMiTO2o0v6Ew/w==",
      "dev": true,
      "license": "MIT",
      "engines": {
        "node": ">= 0.6"
      }
    },
    "node_modules/cookie-signature": {
      "version": "1.0.7",
      "resolved": "https://registry.npmjs.org/cookie-signature/-/cookie-signature-1.0.7.tgz",
      "integrity": "sha512-NXdYc3dLr47pBkpUCHtKSwIOQXLVn8dZEuywboCOJY/osA0wFSLlSawr3KN8qXJEyX66FcONTH8EIlVuK0yyFA==",
      "dev": true,
      "license": "MIT"
    },
    "node_modules/cookiejar": {
      "version": "2.1.4",
      "resolved": "https://registry.npmjs.org/cookiejar/-/cookiejar-2.1.4.tgz",
      "integrity": "sha512-LDx6oHrK+PhzLKJU9j5S7/Y3jM/mUHvD/DeI1WQmJn652iPC5Y4TBzC9l+5OMOXlyTTA+SmVUPm0HQUwpD5Jqw==",
      "dev": true,
      "license": "MIT"
    },
    "node_modules/cors": {
      "version": "2.8.6",
      "resolved": "https://registry.npmjs.org/cors/-/cors-2.8.6.tgz",
      "integrity": "sha512-tJtZBBHA6vjIAaF6EnIaq6laBBP9aq/Y3ouVJjEfoHbRBcHBAHYcMh/w8LDrk2PvIMMq8gmopa5D4V8RmbrxGw==",
      "dev": true,
      "license": "MIT",
      "dependencies": {
        "object-assign": "^4",
        "vary": "^1"
      },
      "engines": {
        "node": ">= 0.10"
      },
      "funding": {
        "type": "opencollective",
        "url": "https://opencollective.com/express"
      }
    },
    "node_modules/csstype": {
      "version": "3.2.3",
      "resolved": "https://registry.npmjs.org/csstype/-/csstype-3.2.3.tgz",
      "integrity": "sha512-z1HGKcYy2xA8AGQfwrn0PAy+PB7X/GSj3UVJW9qKyn43xWa+gl5nXmU4qqLMRzWVLFC8KusUX8T/0kCiOYpAIQ==",
      "dev": true,
      "license": "MIT"
    },
    "node_modules/debug": {
      "version": "4.4.3",
      "resolved": "https://registry.npmjs.org/debug/-/debug-4.4.3.tgz",
      "integrity": "sha512-RGwwWnwQvkVfavKVt22FGLw+xYSdzARwm0ru6DhTVA3umU5hZc28V3kO4stgYryrTlLpuvgI9GiijltAjNbcqA==",
      "dev": true,
      "license": "MIT",
      "dependencies": {
        "ms": "^2.1.3"
      },
      "engines": {
        "node": ">=6.0"
      },
      "peerDependenciesMeta": {
        "supports-color": {
          "optional": true
        }
      }
    },
    "node_modules/delayed-stream": {
      "version": "1.0.0",
      "resolved": "https://registry.npmjs.org/delayed-stream/-/delayed-stream-1.0.0.tgz",
      "integrity": "sha512-ZySD7Nf91aLB0RxL4KGrKHBXl7Eds1DAmEdcoVawXnLD7SDhpNgtuII2aAkg7a7QS41jxPSZ17p4VdGnMHk3MQ==",
      "dev": true,
      "license": "MIT",
      "engines": {
        "node": ">=0.4.0"
      }
    },
    "node_modules/depd": {
      "version": "2.0.0",
      "resolved": "https://registry.npmjs.org/depd/-/depd-2.0.0.tgz",
      "integrity": "sha512-g7nH6P6dyDioJogAAGprGpCtVImJhpPk/roCzdb3fIh61/s/nPsfR6onyMwkCAR/OlC3yBC0lESvUoQEAssIrw==",
      "dev": true,
      "license": "MIT",
      "engines": {
        "node": ">= 0.8"
      }
    },
    "node_modules/destroy": {
      "version": "1.2.0",
      "resolved": "https://registry.npmjs.org/destroy/-/destroy-1.2.0.tgz",
      "integrity": "sha512-2sJGJTaXIIaR1w4iJSNoN0hnMY7Gpc/n8D4qSCJw8QqFWXf7cuAgnEHxBpweaVcPevC2l3KpjYCx3NypQQgaJg==",
      "dev": true,
      "license": "MIT",
      "engines": {
        "node": ">= 0.8",
        "npm": "1.2.8000 || >= 1.4.16"
      }
    },
    "node_modules/detect-libc": {
      "version": "2.1.2",
      "resolved": "https://registry.npmjs.org/detect-libc/-/detect-libc-2.1.2.tgz",
      "integrity": "sha512-Btj2BOOO83o3WyH59e8MgXsxEQVcarkUOpEYrubB0urwnN10yQ364rsiByU11nZlqWYZm05i/of7io4mzihBtQ==",
      "dev": true,
      "license": "Apache-2.0",
      "engines": {
        "node": ">=8"
      }
    },
    "node_modules/dezalgo": {
      "version": "1.0.4",
      "resolved": "https://registry.npmjs.org/dezalgo/-/dezalgo-1.0.4.tgz",
      "integrity": "sha512-rXSP0bf+5n0Qonsb+SVVfNfIsimO4HEtmnIpPHY8Q1UCzKlQrDMfdobr8nJOOsRgWCyMRqeSBQzmWUMq7zvVig==",
      "dev": true,
      "license": "ISC",
      "dependencies": {
        "asap": "^2.0.0",
        "wrappy": "1"
      }
    },
    "node_modules/dunder-proto": {
      "version": "1.0.1",
      "resolved": "https://registry.npmjs.org/dunder-proto/-/dunder-proto-1.0.1.tgz",
      "integrity": "sha512-KIN/nDJBQRcXw0MLVhZE9iQHmG68qAVIBg9CqmUYjmQIhgij9U5MFvrqkUL5FbtyyzZuOeOt0zdeRe4UY7ct+A==",
      "dev": true,
      "license": "MIT",
      "dependencies": {
        "call-bind-apply-helpers": "^1.0.1",
        "es-errors": "^1.3.0",
        "gopd": "^1.2.0"
      },
      "engines": {
        "node": ">= 0.4"
      }
    },
    "node_modules/ecdsa-sig-formatter": {
      "version": "1.0.11",
      "resolved": "https://registry.npmjs.org/ecdsa-sig-formatter/-/ecdsa-sig-formatter-1.0.11.tgz",
      "integrity": "sha512-nagl3RYrbNv6kQkeJIpt6NJZy8twLB/2vtz6yN9Z4vRKHN4/QZJIEbqohALSgwKdnksuY3k5Addp5lg8sVoVcQ==",
      "dev": true,
      "license": "Apache-2.0",
      "dependencies": {
        "safe-buffer": "^5.0.1"
      }
    },
    "node_modules/ee-first": {
      "version": "1.1.1",
      "resolved": "https://registry.npmjs.org/ee-first/-/ee-first-1.1.1.tgz",
      "integrity": "sha512-WMwm9LhRUo+WUaRN+vRuETqG89IgZphVSNkdFgeb6sS/E4OrDIN7t48CAewSHXc6C8lefD8KKfr5vY61brQlow==",
      "dev": true,
      "license": "MIT"
    },
    "node_modules/emoji-regex": {
      "version": "10.6.0",
      "resolved": "https://registry.npmjs.org/emoji-regex/-/emoji-regex-10.6.0.tgz",
      "integrity": "sha512-toUI84YS5YmxW219erniWD0CIVOo46xGKColeNQRgOzDorgBi1v4D71/OFzgD9GO2UGKIv1C3Sp8DAn0+j5w7A==",
      "dev": true,
      "license": "MIT"
    },
    "node_modules/encodeurl": {
      "version": "2.0.0",
      "resolved": "https://registry.npmjs.org/encodeurl/-/encodeurl-2.0.0.tgz",
      "integrity": "sha512-Q0n9HRi4m6JuGIV1eFlmvJB7ZEVxu93IrMyiMsGC0lrMJMWzRgx6WGquyfQgZVb31vhGgXnfmPNNXmxnOkRBrg==",
      "dev": true,
      "license": "MIT",
      "engines": {
        "node": ">= 0.8"
      }
    },
    "node_modules/es-define-property": {
      "version": "1.0.1",
      "resolved": "https://registry.npmjs.org/es-define-property/-/es-define-property-1.0.1.tgz",
      "integrity": "sha512-e3nRfgfUZ4rNGL232gUgX06QNyyez04KdjFrF+LTRoOXmrOgFKDg4BCdsjW8EnT69eqdYGmRpJwiPVYNrCaW3g==",
      "dev": true,
      "license": "MIT",
      "engines": {
        "node": ">= 0.4"
      }
    },
    "node_modules/es-errors": {
      "version": "1.3.0",
      "resolved": "https://registry.npmjs.org/es-errors/-/es-errors-1.3.0.tgz",
      "integrity": "sha512-Zf5H2Kxt2xjTvbJvP2ZWLEICxA6j+hAmMzIlypy4xcBg1vKVnx89Wy0GbS+kf5cwCVFFzdCFh2XSCFNULS6csw==",
      "dev": true,
      "license": "MIT",
      "engines": {
        "node": ">= 0.4"
      }
    },
    "node_modules/es-module-lexer": {
      "version": "2.1.0",
      "resolved": "https://registry.npmjs.org/es-module-lexer/-/es-module-lexer-2.1.0.tgz",
      "integrity": "sha512-n27zTYMjYu1aj4MjCWzSP7G9r75utsaoc8m61weK+W8JMBGGQybd43GstCXZ3WNmSFtGT9wi59qQTW6mhTR5LQ==",
      "dev": true,
      "license": "MIT"
    },
    "node_modules/es-object-atoms": {
      "version": "1.1.2",
      "resolved": "https://registry.npmjs.org/es-object-atoms/-/es-object-atoms-1.1.2.tgz",
      "integrity": "sha512-HWcBoN6NileqtSydK2FqHbS/LoDd2pqrnQHLyJzBj4kOp/ky2MWMN694xOfkK8/SnUsW2DH7EfyVlydKCsm1Zw==",
      "dev": true,
      "license": "MIT",
      "dependencies": {
        "es-errors": "^1.3.0"
      },
      "engines": {
        "node": ">= 0.4"
      }
    },
    "node_modules/es-set-tostringtag": {
      "version": "2.1.0",
      "resolved": "https://registry.npmjs.org/es-set-tostringtag/-/es-set-tostringtag-2.1.0.tgz",
      "integrity": "sha512-j6vWzfrGVfyXxge+O0x5sh6cvxAog0a/4Rdd2K36zCMV5eJ+/+tOAngRO8cODMNWbVRdVlmGZQL2YS3yR8bIUA==",
      "dev": true,
      "license": "MIT",
      "dependencies": {
        "es-errors": "^1.3.0",
        "get-intrinsic": "^1.2.6",
        "has-tostringtag": "^1.0.2",
        "hasown": "^2.0.2"
      },
      "engines": {
        "node": ">= 0.4"
      }
    },
    "node_modules/escalade": {
      "version": "3.2.0",
      "resolved": "https://registry.npmjs.org/escalade/-/escalade-3.2.0.tgz",
      "integrity": "sha512-WUj2qlxaQtO4g6Pq5c29GTcWGDyd8itL8zTlipgECz3JesAiiOKotd8JU6otB3PACgG6xkJUyVhboMS+bje/jA==",
      "dev": true,
      "license": "MIT",
      "engines": {
        "node": ">=6"
      }
    },
    "node_modules/escape-html": {
      "version": "1.0.3",
      "resolved": "https://registry.npmjs.org/escape-html/-/escape-html-1.0.3.tgz",
      "integrity": "sha512-NiSupZ4OeuGwr68lGIeym/ksIZMJodUGOSCZ/FSnTxcrekbvqrgdUxlJOMpijaKZVjAJrWrGs/6Jy8OMuyj9ow==",
      "dev": true,
      "license": "MIT"
    },
    "node_modules/estree-walker": {
      "version": "3.0.3",
      "resolved": "https://registry.npmjs.org/estree-walker/-/estree-walker-3.0.3.tgz",
      "integrity": "sha512-7RUKfXgSMMkzt6ZuXmqapOurLGPPfgj6l9uRZ7lRGolvk0y2yocc35LdcxKC5PQZdn2DMqioAQ2NoWcrTKmm6g==",
      "dev": true,
      "license": "MIT",
      "dependencies": {
        "@types/estree": "^1.0.0"
      }
    },
    "node_modules/etag": {
      "version": "1.8.1",
      "resolved": "https://registry.npmjs.org/etag/-/etag-1.8.1.tgz",
      "integrity": "sha512-aIL5Fx7mawVa300al2BnEE4iNvo1qETxLrPI/o05L7z6go7fCw1J6EQmbK4FmJ2AS7kgVF/KEZWufBfdClMcPg==",
      "dev": true,
      "license": "MIT",
      "engines": {
        "node": ">= 0.6"
      }
    },
    "node_modules/expect-type": {
      "version": "1.3.0",
      "resolved": "https://registry.npmjs.org/expect-type/-/expect-type-1.3.0.tgz",
      "integrity": "sha512-knvyeauYhqjOYvQ66MznSMs83wmHrCycNEN6Ao+2AeYEfxUIkuiVxdEa1qlGEPK+We3n0THiDciYSsCcgW/DoA==",
      "dev": true,
      "license": "Apache-2.0",
      "engines": {
        "node": ">=12.0.0"
      }
    },
    "node_modules/express": {
      "version": "4.22.2",
      "resolved": "https://registry.npmjs.org/express/-/express-4.22.2.tgz",
      "integrity": "sha512-IuL+Elrou2ZvCFHs18/CIzy2Nzvo25nZ1/D2eIZlz7c+QUayAcYoiM2BthCjs+EBHVpjYjcuLDAiCWgeIX3X1Q==",
      "dev": true,
      "license": "MIT",
      "dependencies": {
        "accepts": "~1.3.8",
        "array-flatten": "1.1.1",
        "body-parser": "~1.20.5",
        "content-disposition": "~0.5.4",
        "content-type": "~1.0.4",
        "cookie": "~0.7.1",
        "cookie-signature": "~1.0.6",
        "debug": "2.6.9",
        "depd": "2.0.0",
        "encodeurl": "~2.0.0",
        "escape-html": "~1.0.3",
        "etag": "~1.8.1",
        "finalhandler": "~1.3.1",
        "fresh": "~0.5.2",
        "http-errors": "~2.0.0",
        "merge-descriptors": "1.0.3",
        "methods": "~1.1.2",
        "on-finished": "~2.4.1",
        "parseurl": "~1.3.3",
        "path-to-regexp": "~0.1.12",
        "proxy-addr": "~2.0.7",
        "qs": "~6.15.1",
        "range-parser": "~1.2.1",
        "safe-buffer": "5.2.1",
        "send": "~0.19.0",
        "serve-static": "~1.16.2",
        "setprototypeof": "1.2.0",
        "statuses": "~2.0.1",
        "type-is": "~1.6.18",
        "utils-merge": "1.0.1",
        "vary": "~1.1.2"
      },
      "engines": {
        "node": ">= 0.10.0"
      },
      "funding": {
        "type": "opencollective",
        "url": "https://opencollective.com/express"
      }
    },
    "node_modules/express/node_modules/debug": {
      "version": "2.6.9",
      "resolved": "https://registry.npmjs.org/debug/-/debug-2.6.9.tgz",
      "integrity": "sha512-bC7ElrdJaJnPbAP+1EotYvqZsb3ecl5wi6Bfi6BJTUcNowp6cvspg0jXznRTKDjm/E7AdgFBVeAPVMNcKGsHMA==",
      "dev": true,
      "license": "MIT",
      "dependencies": {
        "ms": "2.0.0"
      }
    },
    "node_modules/express/node_modules/ms": {
      "version": "2.0.0",
      "resolved": "https://registry.npmjs.org/ms/-/ms-2.0.0.tgz",
      "integrity": "sha512-Tpp60P6IUJDTuOq/5Z8cdskzJujfwqfOTkrwIwj7IRISpnkJnT6SyJ4PCPnGMoFjC9ddhal5KVIYtAt97ix05A==",
      "dev": true,
      "license": "MIT"
    },
    "node_modules/fast-safe-stringify": {
      "version": "2.1.1",
      "resolved": "https://registry.npmjs.org/fast-safe-stringify/-/fast-safe-stringify-2.1.1.tgz",
      "integrity": "sha512-W+KJc2dmILlPplD/H4K9l9LcAHAfPtP6BY84uVLXQ6Evcz9Lcg33Y2z1IVblT6xdY54PXYVHEv+0Wpq8Io6zkA==",
      "dev": true,
      "license": "MIT"
    },
    "node_modules/fdir": {
      "version": "6.5.0",
      "resolved": "https://registry.npmjs.org/fdir/-/fdir-6.5.0.tgz",
      "integrity": "sha512-tIbYtZbucOs0BRGqPJkshJUYdL+SDH7dVM8gjy+ERp3WAUjLEFJE+02kanyHtwjWOnwrKYBiwAmM0p4kLJAnXg==",
      "dev": true,
      "license": "MIT",
      "engines": {
        "node": ">=12.0.0"
      },
      "peerDependencies": {
        "picomatch": "^3 || ^4"
      },
      "peerDependenciesMeta": {
        "picomatch": {
          "optional": true
        }
      }
    },
    "node_modules/finalhandler": {
      "version": "1.3.2",
      "resolved": "https://registry.npmjs.org/finalhandler/-/finalhandler-1.3.2.tgz",
      "integrity": "sha512-aA4RyPcd3badbdABGDuTXCMTtOneUCAYH/gxoYRTZlIJdF0YPWuGqiAsIrhNnnqdXGswYk6dGujem4w80UJFhg==",
      "dev": true,
      "license": "MIT",
      "dependencies": {
        "debug": "2.6.9",
        "encodeurl": "~2.0.0",
        "escape-html": "~1.0.3",
        "on-finished": "~2.4.1",
        "parseurl": "~1.3.3",
        "statuses": "~2.0.2",
        "unpipe": "~1.0.0"
      },
      "engines": {
        "node": ">= 0.8"
      }
    },
    "node_modules/finalhandler/node_modules/debug": {
      "version": "2.6.9",
      "resolved": "https://registry.npmjs.org/debug/-/debug-2.6.9.tgz",
      "integrity": "sha512-bC7ElrdJaJnPbAP+1EotYvqZsb3ecl5wi6Bfi6BJTUcNowp6cvspg0jXznRTKDjm/E7AdgFBVeAPVMNcKGsHMA==",
      "dev": true,
      "license": "MIT",
      "dependencies": {
        "ms": "2.0.0"
      }
    },
    "node_modules/finalhandler/node_modules/ms": {
      "version": "2.0.0",
      "resolved": "https://registry.npmjs.org/ms/-/ms-2.0.0.tgz",
      "integrity": "sha512-Tpp60P6IUJDTuOq/5Z8cdskzJujfwqfOTkrwIwj7IRISpnkJnT6SyJ4PCPnGMoFjC9ddhal5KVIYtAt97ix05A==",
      "dev": true,
      "license": "MIT"
    },
    "node_modules/form-data": {
      "version": "4.0.6",
      "resolved": "https://registry.npmjs.org/form-data/-/form-data-4.0.6.tgz",
      "integrity": "sha512-vKatAh4SlVfgbv+YtmhiRjhEMJsYpsG1Y2rMQtR+SVSbytsSD1YGzDIcrAJmdFec88u/+VoGmxnl+80gL1tRCQ==",
      "dev": true,
      "license": "MIT",
      "dependencies": {
        "asynckit": "^0.4.0",
        "combined-stream": "^1.0.8",
        "es-set-tostringtag": "^2.1.0",
        "hasown": "^2.0.4",
        "mime-types": "^2.1.35"
      },
      "engines": {
        "node": ">= 6"
      }
    },
    "node_modules/formidable": {
      "version": "3.5.4",
      "resolved": "https://registry.npmjs.org/formidable/-/formidable-3.5.4.tgz",
      "integrity": "sha512-YikH+7CUTOtP44ZTnUhR7Ic2UASBPOqmaRkRKxRbywPTe5VxF7RRCck4af9wutiZ/QKM5nME9Bie2fFaPz5Gug==",
      "dev": true,
      "license": "MIT",
      "dependencies": {
        "@paralleldrive/cuid2": "^2.2.2",
        "dezalgo": "^1.0.4",
        "once": "^1.4.0"
      },
      "engines": {
        "node": ">=14.0.0"
      },
      "funding": {
        "url": "https://ko-fi.com/tunnckoCore/commissions"
      }
    },
    "node_modules/forwarded": {
      "version": "0.2.0",
      "resolved": "https://registry.npmjs.org/forwarded/-/forwarded-0.2.0.tgz",
      "integrity": "sha512-buRG0fpBtRHSTCOASe6hD258tEubFoRLb4ZNA6NxMVHNw2gOcwHo9wyablzMzOA5z9xA9L1KNjk/Nt6MT9aYow==",
      "dev": true,
      "license": "MIT",
      "engines": {
        "node": ">= 0.6"
      }
    },
    "node_modules/fresh": {
      "version": "0.5.2",
      "resolved": "https://registry.npmjs.org/fresh/-/fresh-0.5.2.tgz",
      "integrity": "sha512-zJ2mQYM18rEFOudeV4GShTGIQ7RbzA7ozbU9I/XBpm7kqgMywgmylMwXHxZJmkVoYkna9d2pVXVXPdYTP9ej8Q==",
      "dev": true,
      "license": "MIT",
      "engines": {
        "node": ">= 0.6"
      }
    },
    "node_modules/fsevents": {
      "version": "2.3.3",
      "resolved": "https://registry.npmjs.org/fsevents/-/fsevents-2.3.3.tgz",
      "integrity": "sha512-5xoDfX+fL7faATnagmWPpbFtwh/R77WmMMqqHGS65C3vvB0YHrgF+B1YmZ3441tMj5n63k0212XNoJwzlhffQw==",
      "dev": true,
      "hasInstallScript": true,
      "license": "MIT",
      "optional": true,
      "os": [
        "darwin"
      ],
      "engines": {
        "node": "^8.16.0 || ^10.6.0 || >=11.0.0"
      }
    },
    "node_modules/function-bind": {
      "version": "1.1.2",
      "resolved": "https://registry.npmjs.org/function-bind/-/function-bind-1.1.2.tgz",
      "integrity": "sha512-7XHNxH7qX9xG5mIwxkhumTox/MIRNcOgDrxWsMt2pAr23WHp6MrRlN7FBSFpCpr+oVO0F744iUgR82nJMfG2SA==",
      "dev": true,
      "license": "MIT",
      "funding": {
        "url": "https://github.com/sponsors/ljharb"
      }
    },
    "node_modules/get-caller-file": {
      "version": "2.0.5",
      "resolved": "https://registry.npmjs.org/get-caller-file/-/get-caller-file-2.0.5.tgz",
      "integrity": "sha512-DyFP3BM/3YHTQOCUL/w0OZHR0lpKeGrxotcHWcqNEdnltqFwXVfhEBQ94eIo34AfQpo0rGki4cyIiftY06h2Fg==",
      "dev": true,
      "license": "ISC",
      "engines": {
        "node": "6.* || 8.* || >= 10.*"
      }
    },
    "node_modules/get-east-asian-width": {
      "version": "1.6.0",
      "resolved": "https://registry.npmjs.org/get-east-asian-width/-/get-east-asian-width-1.6.0.tgz",
      "integrity": "sha512-QRbvDIbx6YklUe6RxeTeleMR0yv3cYH6PsPZHcnVn7xv7zO1BHN8r0XETu8n6Ye3Q+ahtSarc3WgtNWmehIBfA==",
      "dev": true,
      "license": "MIT",
      "engines": {
        "node": ">=18"
      },
      "funding": {
        "url": "https://github.com/sponsors/sindresorhus"
      }
    },
    "node_modules/get-intrinsic": {
      "version": "1.3.0",
      "resolved": "https://registry.npmjs.org/get-intrinsic/-/get-intrinsic-1.3.0.tgz",
      "integrity": "sha512-9fSjSaos/fRIVIp+xSJlE6lfwhES7LNtKaCBIamHsjr2na1BiABJPo0mOjjz8GJDURarmCPGqaiVg5mfjb98CQ==",
      "dev": true,
      "license": "MIT",
      "dependencies": {
        "call-bind-apply-helpers": "^1.0.2",
        "es-define-property": "^1.0.1",
        "es-errors": "^1.3.0",
        "es-object-atoms": "^1.1.1",
        "function-bind": "^1.1.2",
        "get-proto": "^1.0.1",
        "gopd": "^1.2.0",
        "has-symbols": "^1.1.0",
        "hasown": "^2.0.2",
        "math-intrinsics": "^1.1.0"
      },
      "engines": {
        "node": ">= 0.4"
      },
      "funding": {
        "url": "https://github.com/sponsors/ljharb"
      }
    },
    "node_modules/get-proto": {
      "version": "1.0.1",
      "resolved": "https://registry.npmjs.org/get-proto/-/get-proto-1.0.1.tgz",
      "integrity": "sha512-sTSfBjoXBp89JvIKIefqw7U2CCebsc74kiY6awiGogKtoSGbgjYE/G/+l9sF3MWFPNc9IcoOC4ODfKHfxFmp0g==",
      "dev": true,
      "license": "MIT",
      "dependencies": {
        "dunder-proto": "^1.0.1",
        "es-object-atoms": "^1.0.0"
      },
      "engines": {
        "node": ">= 0.4"
      }
    },
    "node_modules/gopd": {
      "version": "1.2.0",
      "resolved": "https://registry.npmjs.org/gopd/-/gopd-1.2.0.tgz",
      "integrity": "sha512-ZUKRh6/kUFoAiTAtTYPZJ3hw9wNxx+BIBOijnlG9PnrJsCcSjs1wyyD6vJpaYtgnzDrKYRSqf3OO6Rfa93xsRg==",
      "dev": true,
      "license": "MIT",
      "engines": {
        "node": ">= 0.4"
      },
      "funding": {
        "url": "https://github.com/sponsors/ljharb"
      }
    },
    "node_modules/has-flag": {
      "version": "4.0.0",
      "resolved": "https://registry.npmjs.org/has-flag/-/has-flag-4.0.0.tgz",
      "integrity": "sha512-EykJT/Q1KjTWctppgIAgfSO0tKVuZUjhgMr17kqTumMl6Afv3EISleU7qZUzoXDFTAHTDC4NOoG/ZxU3EvlMPQ==",
      "dev": true,
      "license": "MIT",
      "engines": {
        "node": ">=8"
      }
    },
    "node_modules/has-symbols": {
      "version": "1.1.0",
      "resolved": "https://registry.npmjs.org/has-symbols/-/has-symbols-1.1.0.tgz",
      "integrity": "sha512-1cDNdwJ2Jaohmb3sg4OmKaMBwuC48sYni5HUw2DvsC8LjGTLK9h+eb1X6RyuOHe4hT0ULCW68iomhjUoKUqlPQ==",
      "dev": true,
      "license": "MIT",
      "engines": {
        "node": ">= 0.4"
      },
      "funding": {
        "url": "https://github.com/sponsors/ljharb"
      }
    },
    "node_modules/has-tostringtag": {
      "version": "1.0.2",
      "resolved": "https://registry.npmjs.org/has-tostringtag/-/has-tostringtag-1.0.2.tgz",
      "integrity": "sha512-NqADB8VjPFLM2V0VvHUewwwsw0ZWBaIdgo+ieHtK3hasLz4qeCRjYcqfB6AQrBggRKppKF8L52/VqdVsO47Dlw==",
      "dev": true,
      "license": "MIT",
      "dependencies": {
        "has-symbols": "^1.0.3"
      },
      "engines": {
        "node": ">= 0.4"
      },
      "funding": {
        "url": "https://github.com/sponsors/ljharb"
      }
    },
    "node_modules/hasown": {
      "version": "2.0.4",
      "resolved": "https://registry.npmjs.org/hasown/-/hasown-2.0.4.tgz",
      "integrity": "sha512-T2UbfbBEF32wiepXIsMlTW9+dDYC6wMh/t/vYA4tuOMKqWz/n3vr1NFSxQiyP+zk2mXsoMA/i/7qV6LKut1t1A==",
      "dev": true,
      "license": "MIT",
      "dependencies": {
        "function-bind": "^1.1.2"
      },
      "engines": {
        "node": ">= 0.4"
      }
    },
    "node_modules/html-escaper": {
      "version": "2.0.2",
      "resolved": "https://registry.npmjs.org/html-escaper/-/html-escaper-2.0.2.tgz",
      "integrity": "sha512-H2iMtd0I4Mt5eYiapRdIDjp+XzelXQ0tFE4JS7YFwFevXXMmOp9myNrUvCg0D6ws8iqkRPBfKHgbwig1SmlLfg==",
      "dev": true,
      "license": "MIT"
    },
    "node_modules/http-errors": {
      "version": "2.0.1",
      "resolved": "https://registry.npmjs.org/http-errors/-/http-errors-2.0.1.tgz",
      "integrity": "sha512-4FbRdAX+bSdmo4AUFuS0WNiPz8NgFt+r8ThgNWmlrjQjt1Q7ZR9+zTlce2859x4KSXrwIsaeTqDoKQmtP8pLmQ==",
      "dev": true,
      "license": "MIT",
      "dependencies": {
        "depd": "~2.0.0",
        "inherits": "~2.0.4",
        "setprototypeof": "~1.2.0",
        "statuses": "~2.0.2",
        "toidentifier": "~1.0.1"
      },
      "engines": {
        "node": ">= 0.8"
      },
      "funding": {
        "type": "opencollective",
        "url": "https://opencollective.com/express"
      }
    },
    "node_modules/iconv-lite": {
      "version": "0.4.24",
      "resolved": "https://registry.npmjs.org/iconv-lite/-/iconv-lite-0.4.24.tgz",
      "integrity": "sha512-v3MXnZAcvnywkTUEZomIActle7RXXeedOR31wwl7VlyoXO4Qi9arvSenNQWne1TcRwhCL1HwLI21bEqdpj8/rA==",
      "dev": true,
      "license": "MIT",
      "dependencies": {
        "safer-buffer": ">= 2.1.2 < 3"
      },
      "engines": {
        "node": ">=0.10.0"
      }
    },
    "node_modules/inherits": {
      "version": "2.0.4",
      "resolved": "https://registry.npmjs.org/inherits/-/inherits-2.0.4.tgz",
      "integrity": "sha512-k/vGaX4/Yla3WzyMCvTQOXYeIHvqOKtnqBduzTHpzpQZzAskKMhZ2K+EnBiSM9zGSoIFeMpXKxa4dYeZIQqewQ==",
      "dev": true,
      "license": "ISC"
    },
    "node_modules/ipaddr.js": {
      "version": "1.9.1",
      "resolved": "https://registry.npmjs.org/ipaddr.js/-/ipaddr.js-1.9.1.tgz",
      "integrity": "sha512-0KI/607xoxSToH7GjN1FfSbLoU0+btTicjsQSWQlh/hZykN8KpmMf7uYwPW3R+akZ6R/w18ZlXSHBYXiYUPO3g==",
      "dev": true,
      "license": "MIT",
      "engines": {
        "node": ">= 0.10"
      }
    },
    "node_modules/istanbul-lib-coverage": {
      "version": "3.2.2",
      "resolved": "https://registry.npmjs.org/istanbul-lib-coverage/-/istanbul-lib-coverage-3.2.2.tgz",
      "integrity": "sha512-O8dpsF+r0WV/8MNRKfnmrtCWhuKjxrq2w+jpzBL5UZKTi2LeVWnWOmWRxFlesJONmc+wLAGvKQZEOanko0LFTg==",
      "dev": true,
      "license": "BSD-3-Clause",
      "engines": {
        "node": ">=8"
      }
    },
    "node_modules/istanbul-lib-report": {
      "version": "3.0.1",
      "resolved": "https://registry.npmjs.org/istanbul-lib-report/-/istanbul-lib-report-3.0.1.tgz",
      "integrity": "sha512-GCfE1mtsHGOELCU8e/Z7YWzpmybrx/+dSTfLrvY8qRmaY6zXTKWn6WQIjaAFw069icm6GVMNkgu0NzI4iPZUNw==",
      "dev": true,
      "license": "BSD-3-Clause",
      "dependencies": {
        "istanbul-lib-coverage": "^3.0.0",
        "make-dir": "^4.0.0",
        "supports-color": "^7.1.0"
      },
      "engines": {
        "node": ">=10"
      }
    },
    "node_modules/istanbul-lib-report/node_modules/supports-color": {
      "version": "7.2.0",
      "resolved": "https://registry.npmjs.org/supports-color/-/supports-color-7.2.0.tgz",
      "integrity": "sha512-qpCAvRl9stuOHveKsn7HncJRvv501qIacKzQlO/+Lwxc9+0q2wLyv4Dfvt80/DPn2pqOBsJdDiogXGR9+OvwRw==",
      "dev": true,
      "license": "MIT",
      "dependencies": {
        "has-flag": "^4.0.0"
      },
      "engines": {
        "node": ">=8"
      }
    },
    "node_modules/istanbul-reports": {
      "version": "3.2.0",
      "resolved": "https://registry.npmjs.org/istanbul-reports/-/istanbul-reports-3.2.0.tgz",
      "integrity": "sha512-HGYWWS/ehqTV3xN10i23tkPkpH46MLCIMFNCaaKNavAXTF1RkqxawEPtnjnGZ6XKSInBKkiOA5BKS+aZiY3AvA==",
      "dev": true,
      "license": "BSD-3-Clause",
      "dependencies": {
        "html-escaper": "^2.0.0",
        "istanbul-lib-report": "^3.0.0"
      },
      "engines": {
        "node": ">=8"
      }
    },
    "node_modules/js-base64": {
      "version": "3.7.8",
      "resolved": "https://registry.npmjs.org/js-base64/-/js-base64-3.7.8.tgz",
      "integrity": "sha512-hNngCeKxIUQiEUN3GPJOkz4wF/YvdUdbNL9hsBcMQTkKzboD7T/q3OYOuuPZLUE6dBxSGpwhk5mwuDud7JVAow==",
      "license": "BSD-3-Clause"
    },
    "node_modules/js-tokens": {
      "version": "4.0.0",
      "resolved": "https://registry.npmjs.org/js-tokens/-/js-tokens-4.0.0.tgz",
      "integrity": "sha512-RdJUflcE3cUzKiMqQgsCu06FPu9UdIJO0beYbPhHN4k6apgJtifcoCtT9bcxOpYBtpD2kCM6Sbzg4CausW/PKQ==",
      "license": "MIT"
    },
    "node_modules/jsonwebtoken": {
      "version": "9.0.3",
      "resolved": "https://registry.npmjs.org/jsonwebtoken/-/jsonwebtoken-9.0.3.tgz",
      "integrity": "sha512-MT/xP0CrubFRNLNKvxJ2BYfy53Zkm++5bX9dtuPbqAeQpTVe0MQTFhao8+Cp//EmJp244xt6Drw/GVEGCUj40g==",
      "dev": true,
      "license": "MIT",
      "dependencies": {
        "jws": "^4.0.1",
        "lodash.includes": "^4.3.0",
        "lodash.isboolean": "^3.0.3",
        "lodash.isinteger": "^4.0.4",
        "lodash.isnumber": "^3.0.3",
        "lodash.isplainobject": "^4.0.6",
        "lodash.isstring": "^4.0.1",
        "lodash.once": "^4.0.0",
        "ms": "^2.1.1",
        "semver": "^7.5.4"
      },
      "engines": {
        "node": ">=12",
        "npm": ">=6"
      }
    },
    "node_modules/jsonwebtoken/node_modules/semver": {
      "version": "7.8.4",
      "resolved": "https://registry.npmjs.org/semver/-/semver-7.8.4.tgz",
      "integrity": "sha512-rUCObTnP32Q08R2uuIrt7r9PlEonuTmtuXYcW6s5kjdlj3xbnwe+21yXptAUYcMAABLkYYTtnmzb3w3EDZfueA==",
      "dev": true,
      "license": "ISC",
      "bin": {
        "semver": "bin/semver.js"
      },
      "engines": {
        "node": ">=10"
      }
    },
    "node_modules/jwa": {
      "version": "2.0.1",
      "resolved": "https://registry.npmjs.org/jwa/-/jwa-2.0.1.tgz",
      "integrity": "sha512-hRF04fqJIP8Abbkq5NKGN0Bbr3JxlQ+qhZufXVr0DvujKy93ZCbXZMHDL4EOtodSbCWxOqR8MS1tXA5hwqCXDg==",
      "dev": true,
      "license": "MIT",
      "dependencies": {
        "buffer-equal-constant-time": "^1.0.1",
        "ecdsa-sig-formatter": "1.0.11",
        "safe-buffer": "^5.0.1"
      }
    },
    "node_modules/jws": {
      "version": "4.0.1",
      "resolved": "https://registry.npmjs.org/jws/-/jws-4.0.1.tgz",
      "integrity": "sha512-EKI/M/yqPncGUUh44xz0PxSidXFr/+r0pA70+gIYhjv+et7yxM+s29Y+VGDkovRofQem0fs7Uvf4+YmAdyRduA==",
      "dev": true,
      "license": "MIT",
      "dependencies": {
        "jwa": "^2.0.1",
        "safe-buffer": "^5.0.1"
      }
    },
    "node_modules/libsql": {
      "version": "0.5.29",
      "resolved": "https://registry.npmjs.org/libsql/-/libsql-0.5.29.tgz",
      "integrity": "sha512-8lMP8iMgiBzzoNbAPQ59qdVcj6UaE/Vnm+fiwX4doX4Narook0a4GPKWBEv+CR8a1OwbfkgL18uBfBjWdF0Fzg==",
      "cpu": [
        "x64",
        "arm64",
        "wasm32",
        "arm"
      ],
      "license": "MIT",
      "os": [
        "darwin",
        "linux",
        "win32"
      ],
      "dependencies": {
        "@neon-rs/load": "^0.0.4",
        "detect-libc": "2.0.2"
      },
      "optionalDependencies": {
        "@libsql/darwin-arm64": "0.5.29",
        "@libsql/darwin-x64": "0.5.29",
        "@libsql/linux-arm-gnueabihf": "0.5.29",
        "@libsql/linux-arm-musleabihf": "0.5.29",
        "@libsql/linux-arm64-gnu": "0.5.29",
        "@libsql/linux-arm64-musl": "0.5.29",
        "@libsql/linux-x64-gnu": "0.5.29",
        "@libsql/linux-x64-musl": "0.5.29",
        "@libsql/win32-x64-msvc": "0.5.29"
      }
    },
    "node_modules/libsql/node_modules/detect-libc": {
      "version": "2.0.2",
      "resolved": "https://registry.npmjs.org/detect-libc/-/detect-libc-2.0.2.tgz",
      "integrity": "sha512-UX6sGumvvqSaXgdKGUsgZWqcUyIXZ/vZTrlRT/iobiKhGL0zL4d3osHj3uqllWJK+i+sixDS/3COVEOFbupFyw==",
      "license": "Apache-2.0",
      "engines": {
        "node": ">=8"
      }
    },
    "node_modules/lightningcss": {
      "version": "1.32.0",
      "resolved": "https://registry.npmjs.org/lightningcss/-/lightningcss-1.32.0.tgz",
      "integrity": "sha512-NXYBzinNrblfraPGyrbPoD19C1h9lfI/1mzgWYvXUTe414Gz/X1FD2XBZSZM7rRTrMA8JL3OtAaGifrIKhQ5yQ==",
      "dev": true,
      "license": "MPL-2.0",
      "dependencies": {
        "detect-libc": "^2.0.3"
      },
      "engines": {
        "node": ">= 12.0.0"
      },
      "funding": {
        "type": "opencollective",
        "url": "https://opencollective.com/parcel"
      },
      "optionalDependencies": {
        "lightningcss-android-arm64": "1.32.0",
        "lightningcss-darwin-arm64": "1.32.0",
        "lightningcss-darwin-x64": "1.32.0",
        "lightningcss-freebsd-x64": "1.32.0",
        "lightningcss-linux-arm-gnueabihf": "1.32.0",
        "lightningcss-linux-arm64-gnu": "1.32.0",
        "lightningcss-linux-arm64-musl": "1.32.0",
        "lightningcss-linux-x64-gnu": "1.32.0",
        "lightningcss-linux-x64-musl": "1.32.0",
        "lightningcss-win32-arm64-msvc": "1.32.0",
        "lightningcss-win32-x64-msvc": "1.32.0"
      }
    },
    "node_modules/lightningcss-android-arm64": {
      "version": "1.32.0",
      "resolved": "https://registry.npmjs.org/lightningcss-android-arm64/-/lightningcss-android-arm64-1.32.0.tgz",
      "integrity": "sha512-YK7/ClTt4kAK0vo6w3X+Pnm0D2cf2vPHbhOXdoNti1Ga0al1P4TBZhwjATvjNwLEBCnKvjJc2jQgHXH0NEwlAg==",
      "cpu": [
        "arm64"
      ],
      "dev": true,
      "license": "MPL-2.0",
      "optional": true,
      "os": [
        "android"
      ],
      "engines": {
        "node": ">= 12.0.0"
      },
      "funding": {
        "type": "opencollective",
        "url": "https://opencollective.com/parcel"
      }
    },
    "node_modules/lightningcss-darwin-arm64": {
      "version": "1.32.0",
      "resolved": "https://registry.npmjs.org/lightningcss-darwin-arm64/-/lightningcss-darwin-arm64-1.32.0.tgz",
      "integrity": "sha512-RzeG9Ju5bag2Bv1/lwlVJvBE3q6TtXskdZLLCyfg5pt+HLz9BqlICO7LZM7VHNTTn/5PRhHFBSjk5lc4cmscPQ==",
      "cpu": [
        "arm64"
      ],
      "dev": true,
      "license": "MPL-2.0",
      "optional": true,
      "os": [
        "darwin"
      ],
      "engines": {
        "node": ">= 12.0.0"
      },
      "funding": {
        "type": "opencollective",
        "url": "https://opencollective.com/parcel"
      }
    },
    "node_modules/lightningcss-darwin-x64": {
      "version": "1.32.0",
      "resolved": "https://registry.npmjs.org/lightningcss-darwin-x64/-/lightningcss-darwin-x64-1.32.0.tgz",
      "integrity": "sha512-U+QsBp2m/s2wqpUYT/6wnlagdZbtZdndSmut/NJqlCcMLTWp5muCrID+K5UJ6jqD2BFshejCYXniPDbNh73V8w==",
      "cpu": [
        "x64"
      ],
      "dev": true,
      "license": "MPL-2.0",
      "optional": true,
      "os": [
        "darwin"
      ],
      "engines": {
        "node": ">= 12.0.0"
      },
      "funding": {
        "type": "opencollective",
        "url": "https://opencollective.com/parcel"
      }
    },
    "node_modules/lightningcss-freebsd-x64": {
      "version": "1.32.0",
      "resolved": "https://registry.npmjs.org/lightningcss-freebsd-x64/-/lightningcss-freebsd-x64-1.32.0.tgz",
      "integrity": "sha512-JCTigedEksZk3tHTTthnMdVfGf61Fky8Ji2E4YjUTEQX14xiy/lTzXnu1vwiZe3bYe0q+SpsSH/CTeDXK6WHig==",
      "cpu": [
        "x64"
      ],
      "dev": true,
      "license": "MPL-2.0",
      "optional": true,
      "os": [
        "freebsd"
      ],
      "engines": {
        "node": ">= 12.0.0"
      },
      "funding": {
        "type": "opencollective",
        "url": "https://opencollective.com/parcel"
      }
    },
    "node_modules/lightningcss-linux-arm-gnueabihf": {
      "version": "1.32.0",
      "resolved": "https://registry.npmjs.org/lightningcss-linux-arm-gnueabihf/-/lightningcss-linux-arm-gnueabihf-1.32.0.tgz",
      "integrity": "sha512-x6rnnpRa2GL0zQOkt6rts3YDPzduLpWvwAF6EMhXFVZXD4tPrBkEFqzGowzCsIWsPjqSK+tyNEODUBXeeVHSkw==",
      "cpu": [
        "arm"
      ],
      "dev": true,
      "license": "MPL-2.0",
      "optional": true,
      "os": [
        "linux"
      ],
      "engines": {
        "node": ">= 12.0.0"
      },
      "funding": {
        "type": "opencollective",
        "url": "https://opencollective.com/parcel"
      }
    },
    "node_modules/lightningcss-linux-arm64-gnu": {
      "version": "1.32.0",
      "resolved": "https://registry.npmjs.org/lightningcss-linux-arm64-gnu/-/lightningcss-linux-arm64-gnu-1.32.0.tgz",
      "integrity": "sha512-0nnMyoyOLRJXfbMOilaSRcLH3Jw5z9HDNGfT/gwCPgaDjnx0i8w7vBzFLFR1f6CMLKF8gVbebmkUN3fa/kQJpQ==",
      "cpu": [
        "arm64"
      ],
      "dev": true,
      "license": "MPL-2.0",
      "optional": true,
      "os": [
        "linux"
      ],
      "engines": {
        "node": ">= 12.0.0"
      },
      "funding": {
        "type": "opencollective",
        "url": "https://opencollective.com/parcel"
      }
    },
    "node_modules/lightningcss-linux-arm64-musl": {
      "version": "1.32.0",
      "resolved": "https://registry.npmjs.org/lightningcss-linux-arm64-musl/-/lightningcss-linux-arm64-musl-1.32.0.tgz",
      "integrity": "sha512-UpQkoenr4UJEzgVIYpI80lDFvRmPVg6oqboNHfoH4CQIfNA+HOrZ7Mo7KZP02dC6LjghPQJeBsvXhJod/wnIBg==",
      "cpu": [
        "arm64"
      ],
      "dev": true,
      "license": "MPL-2.0",
      "optional": true,
      "os": [
        "linux"
      ],
      "engines": {
        "node": ">= 12.0.0"
      },
      "funding": {
        "type": "opencollective",
        "url": "https://opencollective.com/parcel"
      }
    },
    "node_modules/lightningcss-linux-x64-gnu": {
      "version": "1.32.0",
      "resolved": "https://registry.npmjs.org/lightningcss-linux-x64-gnu/-/lightningcss-linux-x64-gnu-1.32.0.tgz",
      "integrity": "sha512-V7Qr52IhZmdKPVr+Vtw8o+WLsQJYCTd8loIfpDaMRWGUZfBOYEJeyJIkqGIDMZPwPx24pUMfwSxxI8phr/MbOA==",
      "cpu": [
        "x64"
      ],
      "dev": true,
      "license": "MPL-2.0",
      "optional": true,
      "os": [
        "linux"
      ],
      "engines": {
        "node": ">= 12.0.0"
      },
      "funding": {
        "type": "opencollective",
        "url": "https://opencollective.com/parcel"
      }
    },
    "node_modules/lightningcss-linux-x64-musl": {
      "version": "1.32.0",
      "resolved": "https://registry.npmjs.org/lightningcss-linux-x64-musl/-/lightningcss-linux-x64-musl-1.32.0.tgz",
      "integrity": "sha512-bYcLp+Vb0awsiXg/80uCRezCYHNg1/l3mt0gzHnWV9XP1W5sKa5/TCdGWaR/zBM2PeF/HbsQv/j2URNOiVuxWg==",
      "cpu": [
        "x64"
      ],
      "dev": true,
      "license": "MPL-2.0",
      "optional": true,
      "os": [
        "linux"
      ],
      "engines": {
        "node": ">= 12.0.0"
      },
      "funding": {
        "type": "opencollective",
        "url": "https://opencollective.com/parcel"
      }
    },
    "node_modules/lightningcss-win32-arm64-msvc": {
      "version": "1.32.0",
      "resolved": "https://registry.npmjs.org/lightningcss-win32-arm64-msvc/-/lightningcss-win32-arm64-msvc-1.32.0.tgz",
      "integrity": "sha512-8SbC8BR40pS6baCM8sbtYDSwEVQd4JlFTOlaD3gWGHfThTcABnNDBda6eTZeqbofalIJhFx0qKzgHJmcPTnGdw==",
      "cpu": [
        "arm64"
      ],
      "dev": true,
      "license": "MPL-2.0",
      "optional": true,
      "os": [
        "win32"
      ],
      "engines": {
        "node": ">= 12.0.0"
      },
      "funding": {
        "type": "opencollective",
        "url": "https://opencollective.com/parcel"
      }
    },
    "node_modules/lightningcss-win32-x64-msvc": {
      "version": "1.32.0",
      "resolved": "https://registry.npmjs.org/lightningcss-win32-x64-msvc/-/lightningcss-win32-x64-msvc-1.32.0.tgz",
      "integrity": "sha512-Amq9B/SoZYdDi1kFrojnoqPLxYhQ4Wo5XiL8EVJrVsB8ARoC1PWW6VGtT0WKCemjy8aC+louJnjS7U18x3b06Q==",
      "cpu": [
        "x64"
      ],
      "dev": true,
      "license": "MPL-2.0",
      "optional": true,
      "os": [
        "win32"
      ],
      "engines": {
        "node": ">= 12.0.0"
      },
      "funding": {
        "type": "opencollective",
        "url": "https://opencollective.com/parcel"
      }
    },
    "node_modules/lodash.includes": {
      "version": "4.3.0",
      "resolved": "https://registry.npmjs.org/lodash.includes/-/lodash.includes-4.3.0.tgz",
      "integrity": "sha512-W3Bx6mdkRTGtlJISOvVD/lbqjTlPPUDTMnlXZFnVwi9NKJ6tiAk6LVdlhZMm17VZisqhKcgzpO5Wz91PCt5b0w==",
      "dev": true,
      "license": "MIT"
    },
    "node_modules/lodash.isboolean": {
      "version": "3.0.3",
      "resolved": "https://registry.npmjs.org/lodash.isboolean/-/lodash.isboolean-3.0.3.tgz",
      "integrity": "sha512-Bz5mupy2SVbPHURB98VAcw+aHh4vRV5IPNhILUCsOzRmsTmSQ17jIuqopAentWoehktxGd9e/hbIXq980/1QJg==",
      "dev": true,
      "license": "MIT"
    },
    "node_modules/lodash.isinteger": {
      "version": "4.0.4",
      "resolved": "https://registry.npmjs.org/lodash.isinteger/-/lodash.isinteger-4.0.4.tgz",
      "integrity": "sha512-DBwtEWN2caHQ9/imiNeEA5ys1JoRtRfY3d7V9wkqtbycnAmTvRRmbHKDV4a0EYc678/dia0jrte4tjYwVBaZUA==",
      "dev": true,
      "license": "MIT"
    },
    "node_modules/lodash.isnumber": {
      "version": "3.0.3",
      "resolved": "https://registry.npmjs.org/lodash.isnumber/-/lodash.isnumber-3.0.3.tgz",
      "integrity": "sha512-QYqzpfwO3/CWf3XP+Z+tkQsfaLL/EnUlXWVkIk5FUPc4sBdTehEqZONuyRt2P67PXAk+NXmTBcc97zw9t1FQrw==",
      "dev": true,
      "license": "MIT"
    },
    "node_modules/lodash.isplainobject": {
      "version": "4.0.6",
      "resolved": "https://registry.npmjs.org/lodash.isplainobject/-/lodash.isplainobject-4.0.6.tgz",
      "integrity": "sha512-oSXzaWypCMHkPC3NvBEaPHf0KsA5mvPrOPgQWDsbg8n7orZ290M0BmC/jgRZ4vcJ6DTAhjrsSYgdsW/F+MFOBA==",
      "dev": true,
      "license": "MIT"
    },
    "node_modules/lodash.isstring": {
      "version": "4.0.1",
      "resolved": "https://registry.npmjs.org/lodash.isstring/-/lodash.isstring-4.0.1.tgz",
      "integrity": "sha512-0wJxfxH1wgO3GrbuP+dTTk7op+6L41QCXbGINEmD+ny/G/eCqGzxyCsh7159S+mgDDcoarnBw6PC1PS5+wUGgw==",
      "dev": true,
      "license": "MIT"
    },
    "node_modules/lodash.once": {
      "version": "4.1.1",
      "resolved": "https://registry.npmjs.org/lodash.once/-/lodash.once-4.1.1.tgz",
      "integrity": "sha512-Sb487aTOCr9drQVL8pIxOzVhafOjZN9UU54hiN8PU3uAiSV7lx1yYNpbNmex2PK6dSJoNTSJUUswT651yww3Mg==",
      "dev": true,
      "license": "MIT"
    },
    "node_modules/loose-envify": {
      "version": "1.4.0",
      "resolved": "https://registry.npmjs.org/loose-envify/-/loose-envify-1.4.0.tgz",
      "integrity": "sha512-lyuxPGr/Wfhrlem2CL/UcnUc1zcqKAImBDzukY7Y5F/yQiNdko6+fRLevlw1HgMySw7f611UIY408EtxRSoK3Q==",
      "license": "MIT",
      "dependencies": {
        "js-tokens": "^3.0.0 || ^4.0.0"
      },
      "bin": {
        "loose-envify": "cli.js"
      }
    },
    "node_modules/magic-string": {
      "version": "0.30.21",
      "resolved": "https://registry.npmjs.org/magic-string/-/magic-string-0.30.21.tgz",
      "integrity": "sha512-vd2F4YUyEXKGcLHoq+TEyCjxueSeHnFxyyjNp80yg0XV4vUhnDer/lvvlqM/arB5bXQN5K2/3oinyCRyx8T2CQ==",
      "dev": true,
      "license": "MIT",
      "dependencies": {
        "@jridgewell/sourcemap-codec": "^1.5.5"
      }
    },
    "node_modules/magicast": {
      "version": "0.5.3",
      "resolved": "https://registry.npmjs.org/magicast/-/magicast-0.5.3.tgz",
      "integrity": "sha512-pVKE4UdSQ7DvHzivsCIFx2BJn1mHG6KsyrFcaxFx6tONdneEuThrDx0Cj3AMg58KyN4pzYT+LHOotxDQDjNvkw==",
      "dev": true,
      "license": "MIT",
      "dependencies": {
        "@babel/parser": "^7.29.3",
        "@babel/types": "^7.29.0",
        "source-map-js": "^1.2.1"
      }
    },
    "node_modules/make-dir": {
      "version": "4.0.0",
      "resolved": "https://registry.npmjs.org/make-dir/-/make-dir-4.0.0.tgz",
      "integrity": "sha512-hXdUTZYIVOt1Ex//jAQi+wTZZpUpwBj/0QsOzqegb3rGMMeJiSEu5xLHnYfBrRV4RH2+OCSOO95Is/7x1WJ4bw==",
      "dev": true,
      "license": "MIT",
      "dependencies": {
        "semver": "^7.5.3"
      },
      "engines": {
        "node": ">=10"
      },
      "funding": {
        "url": "https://github.com/sponsors/sindresorhus"
      }
    },
    "node_modules/make-dir/node_modules/semver": {
      "version": "7.8.5",
      "resolved": "https://registry.npmjs.org/semver/-/semver-7.8.5.tgz",
      "integrity": "sha512-Y7/KDsb8LjooZpwaqGyulO6DQlksgCncchHGk+sZIY4SBvUocMBEFH5Ur1fI4dV+Jvl0w6cjvucaIi40puRioA==",
      "dev": true,
      "license": "ISC",
      "bin": {
        "semver": "bin/semver.js"
      },
      "engines": {
        "node": ">=10"
      }
    },
    "node_modules/math-intrinsics": {
      "version": "1.1.0",
      "resolved": "https://registry.npmjs.org/math-intrinsics/-/math-intrinsics-1.1.0.tgz",
      "integrity": "sha512-/IXtbwEk5HTPyEwyKX6hGkYXxM9nbj64B+ilVJnC/R6B0pH5G4V3b0pVbL7DBj4tkhBAppbQUlf6F6Xl9LHu1g==",
      "dev": true,
      "license": "MIT",
      "engines": {
        "node": ">= 0.4"
      }
    },
    "node_modules/media-typer": {
      "version": "0.3.0",
      "resolved": "https://registry.npmjs.org/media-typer/-/media-typer-0.3.0.tgz",
      "integrity": "sha512-dq+qelQ9akHpcOl/gUVRTxVIOkAJ1wR3QAvb4RsVjS8oVoFjDGTc679wJYmUmknUF5HwMLOgb5O+a3KxfWapPQ==",
      "dev": true,
      "license": "MIT",
      "engines": {
        "node": ">= 0.6"
      }
    },
    "node_modules/merge-descriptors": {
      "version": "1.0.3",
      "resolved": "https://registry.npmjs.org/merge-descriptors/-/merge-descriptors-1.0.3.tgz",
      "integrity": "sha512-gaNvAS7TZ897/rVaZ0nMtAyxNyi/pdbjbAwUpFQpN70GqnVfOiXpeUUMKRBmzXaSQ8DdTX4/0ms62r2K+hE6mQ==",
      "dev": true,
      "license": "MIT",
      "funding": {
        "url": "https://github.com/sponsors/sindresorhus"
      }
    },
    "node_modules/methods": {
      "version": "1.1.2",
      "resolved": "https://registry.npmjs.org/methods/-/methods-1.1.2.tgz",
      "integrity": "sha512-iclAHeNqNm68zFtnZ0e+1L2yUIdvzNoauKU4WBA3VvH/vPFieF7qfRlwUZU+DA9P9bPXIS90ulxoUoCH23sV2w==",
      "dev": true,
      "license": "MIT",
      "engines": {
        "node": ">= 0.6"
      }
    },
    "node_modules/mime": {
      "version": "1.6.0",
      "resolved": "https://registry.npmjs.org/mime/-/mime-1.6.0.tgz",
      "integrity": "sha512-x0Vn8spI+wuJ1O6S7gnbaQg8Pxh4NNHb7KSINmEWKiPE4RKOplvijn+NkmYmmRgP68mc70j2EbeTFRsrswaQeg==",
      "dev": true,
      "license": "MIT",
      "bin": {
        "mime": "cli.js"
      },
      "engines": {
        "node": ">=4"
      }
    },
    "node_modules/mime-types": {
      "version": "2.1.35",
      "resolved": "https://registry.npmjs.org/mime-types/-/mime-types-2.1.35.tgz",
      "integrity": "sha512-ZDY+bPm5zTTF+YpCrAU9nK0UgICYPT0QtT1NZWFv4s++TNkcgVaT0g6+4R2uI4MjQjzysHB1zxuWL50hzaeXiw==",
      "dev": true,
      "license": "MIT",
      "dependencies": {
        "mime-db": "1.52.0"
      },
      "engines": {
        "node": ">= 0.6"
      }
    },
    "node_modules/mime-types/node_modules/mime-db": {
      "version": "1.52.0",
      "resolved": "https://registry.npmjs.org/mime-db/-/mime-db-1.52.0.tgz",
      "integrity": "sha512-sPU4uV7dYlvtWJxwwxHD0PuihVNiE7TyAbQ5SWxDCB9mUYvOgroQOwYQQOKPJ8CIbE+1ETVlOoK1UC2nU3gYvg==",
      "dev": true,
      "license": "MIT",
      "engines": {
        "node": ">= 0.6"
      }
    },
    "node_modules/ms": {
      "version": "2.1.3",
      "resolved": "https://registry.npmjs.org/ms/-/ms-2.1.3.tgz",
      "integrity": "sha512-6FlzubTLZG3J2a/NVCAleEhjzq5oxgHyaCU9yYXvcLsvoVaHJq/s5xXI6/XXP6tz7R9xAOtHnSO/tXtF3WRTlA==",
      "dev": true,
      "license": "MIT"
    },
    "node_modules/nanoid": {
      "version": "3.3.12",
      "resolved": "https://registry.npmjs.org/nanoid/-/nanoid-3.3.12.tgz",
      "integrity": "sha512-ZB9RH/39qpq5Vu6Y+NmUaFhQR6pp+M2Xt76XBnEwDaGcVAqhlvxrl3B2bKS5D3NH3QR76v3aSrKaF/Kiy7lEtQ==",
      "dev": true,
      "funding": [
        {
          "type": "github",
          "url": "https://github.com/sponsors/ai"
        }
      ],
      "license": "MIT",
      "bin": {
        "nanoid": "bin/nanoid.cjs"
      },
      "engines": {
        "node": "^10 || ^12 || ^13.7 || ^14 || >=15.0.1"
      }
    },
    "node_modules/object-assign": {
      "version": "4.1.1",
      "resolved": "https://registry.npmjs.org/object-assign/-/object-assign-4.1.1.tgz",
      "integrity": "sha512-rJgTQnkUnH1sFw8yT6VSU3zD3sWmu6sZhIseY8VX+GRu3P6F7Fu+JNDoXfklElbLJSnc3FUQHVe4cU5hj+BcUg==",
      "dev": true,
      "license": "MIT",
      "engines": {
        "node": ">=0.10.0"
      }
    },
    "node_modules/object-inspect": {
      "version": "1.13.4",
      "resolved": "https://registry.npmjs.org/object-inspect/-/object-inspect-1.13.4.tgz",
      "integrity": "sha512-W67iLl4J2EXEGTbfeHCffrjDfitvLANg0UlX3wFUUSTx92KXRFegMHUVgSqE+wvhAbi4WqjGg9czysTV2Epbew==",
      "dev": true,
      "license": "MIT",
      "engines": {
        "node": ">= 0.4"
      },
      "funding": {
        "url": "https://github.com/sponsors/ljharb"
      }
    },
    "node_modules/obug": {
      "version": "2.1.3",
      "resolved": "https://registry.npmjs.org/obug/-/obug-2.1.3.tgz",
      "integrity": "sha512-9miFgM2OFba7hB+pRgvtV84pYTBaoTHohvmIgiRt6dRIzbwEOIaNaP+dIlGs2fNFoB0SeISs0Jz5WFVRid6Xyg==",
      "dev": true,
      "funding": [
        "https://github.com/sponsors/sxzz",
        "https://opencollective.com/debug"
      ],
      "license": "MIT",
      "engines": {
        "node": ">=12.20.0"
      }
    },
    "node_modules/on-finished": {
      "version": "2.4.1",
      "resolved": "https://registry.npmjs.org/on-finished/-/on-finished-2.4.1.tgz",
      "integrity": "sha512-oVlzkg3ENAhCk2zdv7IJwd/QUD4z2RxRwpkcGY8psCVcCYZNq4wYnVWALHM+brtuJjePWiYF/ClmuDr8Ch5+kg==",
      "dev": true,
      "license": "MIT",
      "dependencies": {
        "ee-first": "1.1.1"
      },
      "engines": {
        "node": ">= 0.8"
      }
    },
    "node_modules/once": {
      "version": "1.4.0",
      "resolved": "https://registry.npmjs.org/once/-/once-1.4.0.tgz",
      "integrity": "sha512-lNaJgI+2Q5URQBkccEKHTQOPaXdUxnZZElQTZY0MFUAuaEqe1E+Nyvgdz/aIyNi6Z9MzO5dv1H8n58/GELp3+w==",
      "dev": true,
      "license": "ISC",
      "dependencies": {
        "wrappy": "1"
      }
    },
    "node_modules/parseurl": {
      "version": "1.3.3",
      "resolved": "https://registry.npmjs.org/parseurl/-/parseurl-1.3.3.tgz",
      "integrity": "sha512-CiyeOxFT/JZyN5m0z9PfXw4SCBJ6Sygz1Dpl0wqjlhDEGGBP1GnsUVEL0p63hoG1fcj3fHynXi9NYO4nWOL+qQ==",
      "dev": true,
      "license": "MIT",
      "engines": {
        "node": ">= 0.8"
      }
    },
    "node_modules/path-to-regexp": {
      "version": "0.1.13",
      "resolved": "https://registry.npmjs.org/path-to-regexp/-/path-to-regexp-0.1.13.tgz",
      "integrity": "sha512-A/AGNMFN3c8bOlvV9RreMdrv7jsmF9XIfDeCd87+I8RNg6s78BhJxMu69NEMHBSJFxKidViTEdruRwEk/WIKqA==",
      "dev": true,
      "license": "MIT"
    },
    "node_modules/pathe": {
      "version": "2.0.3",
      "resolved": "https://registry.npmjs.org/pathe/-/pathe-2.0.3.tgz",
      "integrity": "sha512-WUjGcAqP1gQacoQe+OBJsFA7Ld4DyXuUIjZ5cc75cLHvJ7dtNsTugphxIADwspS+AraAUePCKrSVtPLFj/F88w==",
      "dev": true,
      "license": "MIT"
    },
    "node_modules/picocolors": {
      "version": "1.1.1",
      "resolved": "https://registry.npmjs.org/picocolors/-/picocolors-1.1.1.tgz",
      "integrity": "sha512-xceH2snhtb5M9liqDsmEw56le376mTZkEX/jEb/RxNFyegNul7eNslCXP9FDj/Lcu0X8KEyMceP2ntpaHrDEVA==",
      "dev": true,
      "license": "ISC"
    },
    "node_modules/picomatch": {
      "version": "4.0.4",
      "resolved": "https://registry.npmjs.org/picomatch/-/picomatch-4.0.4.tgz",
      "integrity": "sha512-QP88BAKvMam/3NxH6vj2o21R6MjxZUAd6nlwAS/pnGvN9IVLocLHxGYIzFhg6fUQ+5th6P4dv4eW9jX3DSIj7A==",
      "dev": true,
      "license": "MIT",
      "engines": {
        "node": ">=12"
      },
      "funding": {
        "url": "https://github.com/sponsors/jonschlinkert"
      }
    },
    "node_modules/postcss": {
      "version": "8.5.15",
      "resolved": "https://registry.npmjs.org/postcss/-/postcss-8.5.15.tgz",
      "integrity": "sha512-FfR8sjd4em2T6fb3I2MwAJU7HWVMr9zba+enmQeeWFfCbm+UOC/0X4DS8XtpUTMwWMGbjKYP7xjfNekzyGmB3A==",
      "dev": true,
      "funding": [
        {
          "type": "opencollective",
          "url": "https://opencollective.com/postcss/"
        },
        {
          "type": "tidelift",
          "url": "https://tidelift.com/funding/github/npm/postcss"
        },
        {
          "type": "github",
          "url": "https://github.com/sponsors/ai"
        }
      ],
      "license": "MIT",
      "dependencies": {
        "nanoid": "^3.3.12",
        "picocolors": "^1.1.1",
        "source-map-js": "^1.2.1"
      },
      "engines": {
        "node": "^10 || ^12 || >=14"
      }
    },
    "node_modules/promise-limit": {
      "version": "2.7.0",
      "resolved": "https://registry.npmjs.org/promise-limit/-/promise-limit-2.7.0.tgz",
      "integrity": "sha512-7nJ6v5lnJsXwGprnGXga4wx6d1POjvi5Qmf1ivTRxTjH4Z/9Czja/UCMLVmB9N93GeWOU93XaFaEt6jbuoagNw==",
      "license": "ISC"
    },
    "node_modules/proxy-addr": {
      "version": "2.0.7",
      "resolved": "https://registry.npmjs.org/proxy-addr/-/proxy-addr-2.0.7.tgz",
      "integrity": "sha512-llQsMLSUDUPT44jdrU/O37qlnifitDP+ZwrmmZcoSKyLKvtZxpyV0n2/bD/N4tBAAZ/gJEdZU7KMraoK1+XYAg==",
      "dev": true,
      "license": "MIT",
      "dependencies": {
        "forwarded": "0.2.0",
        "ipaddr.js": "1.9.1"
      },
      "engines": {
        "node": ">= 0.10"
      }
    },
    "node_modules/qs": {
      "version": "6.15.2",
      "resolved": "https://registry.npmjs.org/qs/-/qs-6.15.2.tgz",
      "integrity": "sha512-Rzq0KEyX/w/tEybncDgdkZrJgVUsUMk3xjh3t5bv3S1HTAtg+uOYt72+ZfwiQwKdysThkTBdL/rTi6HDmX9Ddw==",
      "dev": true,
      "license": "BSD-3-Clause",
      "dependencies": {
        "side-channel": "^1.1.0"
      },
      "engines": {
        "node": ">=0.6"
      },
      "funding": {
        "url": "https://github.com/sponsors/ljharb"
      }
    },
    "node_modules/range-parser": {
      "version": "1.2.1",
      "resolved": "https://registry.npmjs.org/range-parser/-/range-parser-1.2.1.tgz",
      "integrity": "sha512-Hrgsx+orqoygnmhFbKaHE6c296J+HTAQXoxEF6gNupROmmGJRoyzfG3ccAveqCBrwr/2yxQ5BVd/GTl5agOwSg==",
      "dev": true,
      "license": "MIT",
      "engines": {
        "node": ">= 0.6"
      }
    },
    "node_modules/raw-body": {
      "version": "2.5.3",
      "resolved": "https://registry.npmjs.org/raw-body/-/raw-body-2.5.3.tgz",
      "integrity": "sha512-s4VSOf6yN0rvbRZGxs8Om5CWj6seneMwK3oDb4lWDH0UPhWcxwOWw5+qk24bxq87szX1ydrwylIOp2uG1ojUpA==",
      "dev": true,
      "license": "MIT",
      "dependencies": {
        "bytes": "~3.1.2",
        "http-errors": "~2.0.1",
        "iconv-lite": "~0.4.24",
        "unpipe": "~1.0.0"
      },
      "engines": {
        "node": ">= 0.8"
      }
    },
    "node_modules/react": {
      "version": "18.3.1",
      "resolved": "https://registry.npmjs.org/react/-/react-18.3.1.tgz",
      "integrity": "sha512-wS+hAgJShR0KhEvPJArfuPVN1+Hz1t0Y6n5jLrGQbkb4urgPE/0Rve+1kMB1v/oWgHgm4WIcV+i7F2pTVj+2iQ==",
      "license": "MIT",
      "dependencies": {
        "loose-envify": "^1.1.0"
      },
      "engines": {
        "node": ">=0.10.0"
      }
    },
    "node_modules/react-dom": {
      "version": "18.3.1",
      "resolved": "https://registry.npmjs.org/react-dom/-/react-dom-18.3.1.tgz",
      "integrity": "sha512-5m4nQKp+rZRb09LNH59GM4BxTh9251/ylbKIbpe7TpGxfJ+9kv6BLkLBXIjjspbgbnIBNqlI23tRnTWT0snUIw==",
      "license": "MIT",
      "dependencies": {
        "loose-envify": "^1.1.0",
        "scheduler": "^0.23.2"
      },
      "peerDependencies": {
        "react": "^18.3.1"
      }
    },
    "node_modules/react-router": {
      "version": "6.30.4",
      "resolved": "https://registry.npmjs.org/react-router/-/react-router-6.30.4.tgz",
      "integrity": "sha512-SVUsDe+DybHM/WmYKIVYhZh1o5Dcuf16yM6WjG02Q9XVFMZIJyHYhwrr6bFBXZkVP6z69kNkMyBCujt8FaFLJA==",
      "license": "MIT",
      "dependencies": {
        "@remix-run/router": "1.23.3"
      },
      "engines": {
        "node": ">=14.0.0"
      },
      "peerDependencies": {
        "react": ">=16.8"
      }
    },
    "node_modules/react-router-dom": {
      "version": "6.30.4",
      "resolved": "https://registry.npmjs.org/react-router-dom/-/react-router-dom-6.30.4.tgz",
      "integrity": "sha512-q4HvNl+mmDdkS0g+MqiBZNteQJCuimWoOyHMy4T/RQLAn9Z29+E91QXRaxOujeMl2HTzRSS0KFPd7lxX3PjV0Q==",
      "license": "MIT",
      "dependencies": {
        "@remix-run/router": "1.23.3",
        "react-router": "6.30.4"
      },
      "engines": {
        "node": ">=14.0.0"
      },
      "peerDependencies": {
        "react": ">=16.8",
        "react-dom": ">=16.8"
      }
    },
    "node_modules/rolldown": {
      "version": "1.1.3",
      "resolved": "https://registry.npmjs.org/rolldown/-/rolldown-1.1.3.tgz",
      "integrity": "sha512-1F1eEtUBtFvcGm1HQ9TiUIUHPQG7mSAODrhIzjxoUEFuo8OcbrGLiVLkevNgj84TE4lnHvnumwFjhJO5Eu135g==",
      "dev": true,
      "license": "MIT",
      "dependencies": {
        "@oxc-project/types": "=0.137.0",
        "@rolldown/pluginutils": "^1.0.0"
      },
      "bin": {
        "rolldown": "bin/cli.mjs"
      },
      "engines": {
        "node": "^20.19.0 || >=22.12.0"
      },
      "optionalDependencies": {
        "@rolldown/binding-android-arm64": "1.1.3",
        "@rolldown/binding-darwin-arm64": "1.1.3",
        "@rolldown/binding-darwin-x64": "1.1.3",
        "@rolldown/binding-freebsd-x64": "1.1.3",
        "@rolldown/binding-linux-arm-gnueabihf": "1.1.3",
        "@rolldown/binding-linux-arm64-gnu": "1.1.3",
        "@rolldown/binding-linux-arm64-musl": "1.1.3",
        "@rolldown/binding-linux-ppc64-gnu": "1.1.3",
        "@rolldown/binding-linux-s390x-gnu": "1.1.3",
        "@rolldown/binding-linux-x64-gnu": "1.1.3",
        "@rolldown/binding-linux-x64-musl": "1.1.3",
        "@rolldown/binding-openharmony-arm64": "1.1.3",
        "@rolldown/binding-wasm32-wasi": "1.1.3",
        "@rolldown/binding-win32-arm64-msvc": "1.1.3",
        "@rolldown/binding-win32-x64-msvc": "1.1.3"
      }
    },
    "node_modules/rxjs": {
      "version": "7.8.2",
      "resolved": "https://registry.npmjs.org/rxjs/-/rxjs-7.8.2.tgz",
      "integrity": "sha512-dhKf903U/PQZY6boNNtAGdWbG85WAbjT/1xYoZIC7FAY0yWapOBQVsVrDl58W86//e1VpMNBtRV4MaXfdMySFA==",
      "dev": true,
      "license": "Apache-2.0",
      "dependencies": {
        "tslib": "^2.1.0"
      }
    },
    "node_modules/safe-buffer": {
      "version": "5.2.1",
      "resolved": "https://registry.npmjs.org/safe-buffer/-/safe-buffer-5.2.1.tgz",
      "integrity": "sha512-rp3So07KcdmmKbGvgaNxQSJr7bGVSVk5S9Eq1F+ppbRo70+YeaDxkw5Dd8NPN+GD6bjnYm2VuPuCXmpuYvmCXQ==",
      "dev": true,
      "funding": [
        {
          "type": "github",
          "url": "https://github.com/sponsors/feross"
        },
        {
          "type": "patreon",
          "url": "https://www.patreon.com/feross"
        },
        {
          "type": "consulting",
          "url": "https://feross.org/support"
        }
      ],
      "license": "MIT"
    },
    "node_modules/safer-buffer": {
      "version": "2.1.2",
      "resolved": "https://registry.npmjs.org/safer-buffer/-/safer-buffer-2.1.2.tgz",
      "integrity": "sha512-YZo3K82SD7Riyi0E1EQPojLz7kpepnSQI9IyPbHHg1XXXevb5dJI7tpyN2ADxGcQbHG7vcyRHk0cbwqcQriUtg==",
      "dev": true,
      "license": "MIT"
    },
    "node_modules/scheduler": {
      "version": "0.23.2",
      "resolved": "https://registry.npmjs.org/scheduler/-/scheduler-0.23.2.tgz",
      "integrity": "sha512-UOShsPwz7NrMUqhR6t0hWjFduvOzbtv7toDH1/hIrfRNIDBnnBWd0CwJTGvTpngVlmwGCdP9/Zl/tVrDqcuYzQ==",
      "license": "MIT",
      "dependencies": {
        "loose-envify": "^1.1.0"
      }
    },
    "node_modules/send": {
      "version": "0.19.2",
      "resolved": "https://registry.npmjs.org/send/-/send-0.19.2.tgz",
      "integrity": "sha512-VMbMxbDeehAxpOtWJXlcUS5E8iXh6QmN+BkRX1GARS3wRaXEEgzCcB10gTQazO42tpNIya8xIyNx8fll1OFPrg==",
      "dev": true,
      "license": "MIT",
      "dependencies": {
        "debug": "2.6.9",
        "depd": "2.0.0",
        "destroy": "1.2.0",
        "encodeurl": "~2.0.0",
        "escape-html": "~1.0.3",
        "etag": "~1.8.1",
        "fresh": "~0.5.2",
        "http-errors": "~2.0.1",
        "mime": "1.6.0",
        "ms": "2.1.3",
        "on-finished": "~2.4.1",
        "range-parser": "~1.2.1",
        "statuses": "~2.0.2"
      },
      "engines": {
        "node": ">= 0.8.0"
      }
    },
    "node_modules/send/node_modules/debug": {
      "version": "2.6.9",
      "resolved": "https://registry.npmjs.org/debug/-/debug-2.6.9.tgz",
      "integrity": "sha512-bC7ElrdJaJnPbAP+1EotYvqZsb3ecl5wi6Bfi6BJTUcNowp6cvspg0jXznRTKDjm/E7AdgFBVeAPVMNcKGsHMA==",
      "dev": true,
      "license": "MIT",
      "dependencies": {
        "ms": "2.0.0"
      }
    },
    "node_modules/send/node_modules/debug/node_modules/ms": {
      "version": "2.0.0",
      "resolved": "https://registry.npmjs.org/ms/-/ms-2.0.0.tgz",
      "integrity": "sha512-Tpp60P6IUJDTuOq/5Z8cdskzJujfwqfOTkrwIwj7IRISpnkJnT6SyJ4PCPnGMoFjC9ddhal5KVIYtAt97ix05A==",
      "dev": true,
      "license": "MIT"
    },
    "node_modules/serve-static": {
      "version": "1.16.3",
      "resolved": "https://registry.npmjs.org/serve-static/-/serve-static-1.16.3.tgz",
      "integrity": "sha512-x0RTqQel6g5SY7Lg6ZreMmsOzncHFU7nhnRWkKgWuMTu5NN0DR5oruckMqRvacAN9d5w6ARnRBXl9xhDCgfMeA==",
      "dev": true,
      "license": "MIT",
      "dependencies": {
        "encodeurl": "~2.0.0",
        "escape-html": "~1.0.3",
        "parseurl": "~1.3.3",
        "send": "~0.19.1"
      },
      "engines": {
        "node": ">= 0.8.0"
      }
    },
    "node_modules/setprototypeof": {
      "version": "1.2.0",
      "resolved": "https://registry.npmjs.org/setprototypeof/-/setprototypeof-1.2.0.tgz",
      "integrity": "sha512-E5LDX7Wrp85Kil5bhZv46j8jOeboKq5JMmYM3gVGdGH8xFpPWXUMsNrlODCrkoxMEeNi/XZIwuRvY4XNwYMJpw==",
      "dev": true,
      "license": "ISC"
    },
    "node_modules/shell-quote": {
      "version": "1.8.4",
      "resolved": "https://registry.npmjs.org/shell-quote/-/shell-quote-1.8.4.tgz",
      "integrity": "sha512-VsC6n6vz1ihYYyZZwX7YZSF5l5x36ca17OC+a69h94YqB7X6XLwf+5MOgynYir2SLFUbl8gIYvBo8K8RoNQ6bQ==",
      "dev": true,
      "license": "MIT",
      "engines": {
        "node": ">= 0.4"
      },
      "funding": {
        "url": "https://github.com/sponsors/ljharb"
      }
    },
    "node_modules/side-channel": {
      "version": "1.1.1",
      "resolved": "https://registry.npmjs.org/side-channel/-/side-channel-1.1.1.tgz",
      "integrity": "sha512-6x6dK6zJdpTzF4sQeNYxwtvBzf6Eg4GtlesS94HOvTudUeyK2WXAaIfmDgsyslYrRBeFIlsi54AYsFGUuhmvrQ==",
      "dev": true,
      "license": "MIT",
      "dependencies": {
        "es-errors": "^1.3.0",
        "object-inspect": "^1.13.4",
        "side-channel-list": "^1.0.1",
        "side-channel-map": "^1.0.1",
        "side-channel-weakmap": "^1.0.2"
      },
      "engines": {
        "node": ">= 0.4"
      },
      "funding": {
        "url": "https://github.com/sponsors/ljharb"
      }
    },
    "node_modules/side-channel-list": {
      "version": "1.0.1",
      "resolved": "https://registry.npmjs.org/side-channel-list/-/side-channel-list-1.0.1.tgz",
      "integrity": "sha512-mjn/0bi/oUURjc5Xl7IaWi/OJJJumuoJFQJfDDyO46+hBWsfaVM65TBHq2eoZBhzl9EchxOijpkbRC8SVBQU0w==",
      "dev": true,
      "license": "MIT",
      "dependencies": {
        "es-errors": "^1.3.0",
        "object-inspect": "^1.13.4"
      },
      "engines": {
        "node": ">= 0.4"
      },
      "funding": {
        "url": "https://github.com/sponsors/ljharb"
      }
    },
    "node_modules/side-channel-map": {
      "version": "1.0.1",
      "resolved": "https://registry.npmjs.org/side-channel-map/-/side-channel-map-1.0.1.tgz",
      "integrity": "sha512-VCjCNfgMsby3tTdo02nbjtM/ewra6jPHmpThenkTYh8pG9ucZ/1P8So4u4FGBek/BjpOVsDCMoLA/iuBKIFXRA==",
      "dev": true,
      "license": "MIT",
      "dependencies": {
        "call-bound": "^1.0.2",
        "es-errors": "^1.3.0",
        "get-intrinsic": "^1.2.5",
        "object-inspect": "^1.13.3"
      },
      "engines": {
        "node": ">= 0.4"
      },
      "funding": {
        "url": "https://github.com/sponsors/ljharb"
      }
    },
    "node_modules/side-channel-weakmap": {
      "version": "1.0.2",
      "resolved": "https://registry.npmjs.org/side-channel-weakmap/-/side-channel-weakmap-1.0.2.tgz",
      "integrity": "sha512-WPS/HvHQTYnHisLo9McqBHOJk2FkHO/tlpvldyrnem4aeQp4hai3gythswg6p01oSoTl58rcpiFAjF2br2Ak2A==",
      "dev": true,
      "license": "MIT",
      "dependencies": {
        "call-bound": "^1.0.2",
        "es-errors": "^1.3.0",
        "get-intrinsic": "^1.2.5",
        "object-inspect": "^1.13.3",
        "side-channel-map": "^1.0.1"
      },
      "engines": {
        "node": ">= 0.4"
      },
      "funding": {
        "url": "https://github.com/sponsors/ljharb"
      }
    },
    "node_modules/siginfo": {
      "version": "2.0.0",
      "resolved": "https://registry.npmjs.org/siginfo/-/siginfo-2.0.0.tgz",
      "integrity": "sha512-ybx0WO1/8bSBLEWXZvEd7gMW3Sn3JFlW3TvX1nREbDLRNQNaeNN8WK0meBwPdAaOI7TtRRRJn/Es1zhrrCHu7g==",
      "dev": true,
      "license": "ISC"
    },
    "node_modules/source-map-js": {
      "version": "1.2.1",
      "resolved": "https://registry.npmjs.org/source-map-js/-/source-map-js-1.2.1.tgz",
      "integrity": "sha512-UXWMKhLOwVKb728IUtQPXxfYU+usdybtUrK/8uGE8CQMvrhOpwvzDBwj0QhSL7MQc7vIsISBG8VQ8+IDQxpfQA==",
      "dev": true,
      "license": "BSD-3-Clause",
      "engines": {
        "node": ">=0.10.0"
      }
    },
    "node_modules/stackback": {
      "version": "0.0.2",
      "resolved": "https://registry.npmjs.org/stackback/-/stackback-0.0.2.tgz",
      "integrity": "sha512-1XMJE5fQo1jGH6Y/7ebnwPOBEkIEnT4QF32d5R1+VXdXveM0IBMJt8zfaxX1P3QhVwrYe+576+jkANtSS2mBbw==",
      "dev": true,
      "license": "MIT"
    },
    "node_modules/statuses": {
      "version": "2.0.2",
      "resolved": "https://registry.npmjs.org/statuses/-/statuses-2.0.2.tgz",
      "integrity": "sha512-DvEy55V3DB7uknRo+4iOGT5fP1slR8wQohVdknigZPMpMstaKJQWhwiYBACJE3Ul2pTnATihhBYnRhZQHGBiRw==",
      "dev": true,
      "license": "MIT",
      "engines": {
        "node": ">= 0.8"
      }
    },
    "node_modules/std-env": {
      "version": "4.1.0",
      "resolved": "https://registry.npmjs.org/std-env/-/std-env-4.1.0.tgz",
      "integrity": "sha512-Rq7ybcX2RuC55r9oaPVEW7/xu3tj8u4GeBYHBWCychFtzMIr86A7e3PPEBPT37sHStKX3+TiX/Fr/ACmJLVlLQ==",
      "dev": true,
      "license": "MIT"
    },
    "node_modules/string-width": {
      "version": "7.2.0",
      "resolved": "https://registry.npmjs.org/string-width/-/string-width-7.2.0.tgz",
      "integrity": "sha512-tsaTIkKW9b4N+AEj+SVA+WhJzV7/zMhcSu78mLKWSk7cXMOSHsBKFWUs0fWwq8QyK3MgJBQRX6Gbi4kYbdvGkQ==",
      "dev": true,
      "license": "MIT",
      "dependencies": {
        "emoji-regex": "^10.3.0",
        "get-east-asian-width": "^1.0.0",
        "strip-ansi": "^7.1.0"
      },
      "engines": {
        "node": ">=18"
      },
      "funding": {
        "url": "https://github.com/sponsors/sindresorhus"
      }
    },
    "node_modules/strip-ansi": {
      "version": "7.2.0",
      "resolved": "https://registry.npmjs.org/strip-ansi/-/strip-ansi-7.2.0.tgz",
      "integrity": "sha512-yDPMNjp4WyfYBkHnjIRLfca1i6KMyGCtsVgoKe/z1+6vukgaENdgGBZt+ZmKPc4gavvEZ5OgHfHdrazhgNyG7w==",
      "dev": true,
      "license": "MIT",
      "dependencies": {
        "ansi-regex": "^6.2.2"
      },
      "engines": {
        "node": ">=12"
      },
      "funding": {
        "url": "https://github.com/chalk/strip-ansi?sponsor=1"
      }
    },
    "node_modules/superagent": {
      "version": "10.3.0",
      "resolved": "https://registry.npmjs.org/superagent/-/superagent-10.3.0.tgz",
      "integrity": "sha512-B+4Ik7ROgVKrQsXTV0Jwp2u+PXYLSlqtDAhYnkkD+zn3yg8s/zjA2MeGayPoY/KICrbitwneDHrjSotxKL+0XQ==",
      "dev": true,
      "license": "MIT",
      "dependencies": {
        "component-emitter": "^1.3.1",
        "cookiejar": "^2.1.4",
        "debug": "^4.3.7",
        "fast-safe-stringify": "^2.1.1",
        "form-data": "^4.0.5",
        "formidable": "^3.5.4",
        "methods": "^1.1.2",
        "mime": "2.6.0",
        "qs": "^6.14.1"
      },
      "engines": {
        "node": ">=14.18.0"
      }
    },
    "node_modules/superagent/node_modules/mime": {
      "version": "2.6.0",
      "resolved": "https://registry.npmjs.org/mime/-/mime-2.6.0.tgz",
      "integrity": "sha512-USPkMeET31rOMiarsBNIHZKLGgvKc/LrjofAnBlOttf5ajRvqiRA8QsenbcooctK6d6Ts6aqZXBA+XbkKthiQg==",
      "dev": true,
      "license": "MIT",
      "bin": {
        "mime": "cli.js"
      },
      "engines": {
        "node": ">=4.0.0"
      }
    },
    "node_modules/supertest": {
      "version": "7.2.2",
      "resolved": "https://registry.npmjs.org/supertest/-/supertest-7.2.2.tgz",
      "integrity": "sha512-oK8WG9diS3DlhdUkcFn4tkNIiIbBx9lI2ClF8K+b2/m8Eyv47LSawxUzZQSNKUrVb2KsqeTDCcjAAVPYaSLVTA==",
      "dev": true,
      "license": "MIT",
      "dependencies": {
        "cookie-signature": "^1.2.2",
        "methods": "^1.1.2",
        "superagent": "^10.3.0"
      },
      "engines": {
        "node": ">=14.18.0"
      }
    },
    "node_modules/supertest/node_modules/cookie-signature": {
      "version": "1.2.2",
      "resolved": "https://registry.npmjs.org/cookie-signature/-/cookie-signature-1.2.2.tgz",
      "integrity": "sha512-D76uU73ulSXrD1UXF4KE2TMxVVwhsnCgfAyTg9k8P6KGZjlXKrOLe4dJQKI3Bxi5wjesZoFXJWElNWBjPZMbhg==",
      "dev": true,
      "license": "MIT",
      "engines": {
        "node": ">=6.6.0"
      }
    },
    "node_modules/supports-color": {
      "version": "10.2.2",
      "resolved": "https://registry.npmjs.org/supports-color/-/supports-color-10.2.2.tgz",
      "integrity": "sha512-SS+jx45GF1QjgEXQx4NJZV9ImqmO2NPz5FNsIHrsDjh2YsHnawpan7SNQ1o8NuhrbHZy9AZhIoCUiCeaW/C80g==",
      "dev": true,
      "license": "MIT",
      "engines": {
        "node": ">=18"
      },
      "funding": {
        "url": "https://github.com/chalk/supports-color?sponsor=1"
      }
    },
    "node_modules/tinybench": {
      "version": "2.9.0",
      "resolved": "https://registry.npmjs.org/tinybench/-/tinybench-2.9.0.tgz",
      "integrity": "sha512-0+DUvqWMValLmha6lr4kD8iAMK1HzV0/aKnCtWb9v9641TnP/MFb7Pc2bxoxQjTXAErryXVgUOfv2YqNllqGeg==",
      "dev": true,
      "license": "MIT"
    },
    "node_modules/tinyexec": {
      "version": "1.2.4",
      "resolved": "https://registry.npmjs.org/tinyexec/-/tinyexec-1.2.4.tgz",
      "integrity": "sha512-SHf/r48b7vOrjve9PxJo3MN5v5yuyjHvdUcrQffT3WXMUfnGmHDVbC4k3sHJaJTgZCwpUplIaAo5ANtMyp3YHg==",
      "dev": true,
      "license": "MIT",
      "engines": {
        "node": ">=18"
      }
    },
    "node_modules/tinyglobby": {
      "version": "0.2.17",
      "resolved": "https://registry.npmjs.org/tinyglobby/-/tinyglobby-0.2.17.tgz",
      "integrity": "sha512-wXR/dYpcqKmfWpEdZjiKJOwCNFndD0DMnrW/cYjVGttEkBfVgcLFHoNrlj47mjOVic9yyNu65alsgF4NQyTa2g==",
      "dev": true,
      "license": "MIT",
      "dependencies": {
        "fdir": "^6.5.0",
        "picomatch": "^4.0.4"
      },
      "engines": {
        "node": ">=12.0.0"
      },
      "funding": {
        "url": "https://github.com/sponsors/SuperchupuDev"
      }
    },
    "node_modules/tinyrainbow": {
      "version": "3.1.0",
      "resolved": "https://registry.npmjs.org/tinyrainbow/-/tinyrainbow-3.1.0.tgz",
      "integrity": "sha512-Bf+ILmBgretUrdJxzXM0SgXLZ3XfiaUuOj/IKQHuTXip+05Xn+uyEYdVg0kYDipTBcLrCVyUzAPz7QmArb0mmw==",
      "dev": true,
      "license": "MIT",
      "engines": {
        "node": ">=14.0.0"
      }
    },
    "node_modules/toidentifier": {
      "version": "1.0.1",
      "resolved": "https://registry.npmjs.org/toidentifier/-/toidentifier-1.0.1.tgz",
      "integrity": "sha512-o5sSPKEkg/DIQNmH43V0/uerLrpzVedkUh8tGNvaeXpfpuwjKenlSox/2O/BTlZUtEe+JG7s5YhEz608PlAHRA==",
      "dev": true,
      "license": "MIT",
      "engines": {
        "node": ">=0.6"
      }
    },
    "node_modules/tree-kill": {
      "version": "1.2.2",
      "resolved": "https://registry.npmjs.org/tree-kill/-/tree-kill-1.2.2.tgz",
      "integrity": "sha512-L0Orpi8qGpRG//Nd+H90vFB+3iHnue1zSSGmNOOCh1GLJ7rUKVwV2HvijphGQS2UmhUZewS9VgvxYIdgr+fG1A==",
      "dev": true,
      "license": "MIT",
      "bin": {
        "tree-kill": "cli.js"
      }
    },
    "node_modules/tslib": {
      "version": "2.8.1",
      "resolved": "https://registry.npmjs.org/tslib/-/tslib-2.8.1.tgz",
      "integrity": "sha512-oJFu94HQb+KVduSUQL7wnpmqnfmLsOA/nAh6b6EH0wCEoK0/mPeXU6c3wKDV83MkOuHPRHtSXKKU99IBazS/2w==",
      "dev": true,
      "license": "0BSD"
    },
    "node_modules/type-is": {
      "version": "1.6.18",
      "resolved": "https://registry.npmjs.org/type-is/-/type-is-1.6.18.tgz",
      "integrity": "sha512-TkRKr9sUTxEH8MdfuCSP7VizJyzRNMjj2J2do2Jr3Kym598JVdEksuzPQCnlFPW4ky9Q+iA+ma9BGm06XQBy8g==",
      "dev": true,
      "license": "MIT",
      "dependencies": {
        "media-typer": "0.3.0",
        "mime-types": "~2.1.24"
      },
      "engines": {
        "node": ">= 0.6"
      }
    },
    "node_modules/typescript": {
      "version": "6.0.3",
      "resolved": "https://registry.npmjs.org/typescript/-/typescript-6.0.3.tgz",
      "integrity": "sha512-y2TvuxSZPDyQakkFRPZHKFm+KKVqIisdg9/CZwm9ftvKXLP8NRWj38/ODjNbr43SsoXqNuAisEf1GdCxqWcdBw==",
      "dev": true,
      "license": "Apache-2.0",
      "bin": {
        "tsc": "bin/tsc",
        "tsserver": "bin/tsserver"
      },
      "engines": {
        "node": ">=14.17"
      }
    },
    "node_modules/undici-types": {
      "version": "7.24.6",
      "resolved": "https://registry.npmjs.org/undici-types/-/undici-types-7.24.6.tgz",
      "integrity": "sha512-WRNW+sJgj5OBN4/0JpHFqtqzhpbnV0GuB+OozA9gCL7a993SmU+1JBZCzLNxYsbMfIeDL+lTsphD5jN5N+n0zg==",
      "license": "MIT"
    },
    "node_modules/unpipe": {
      "version": "1.0.0",
      "resolved": "https://registry.npmjs.org/unpipe/-/unpipe-1.0.0.tgz",
      "integrity": "sha512-pjy2bYhSsufwWlKwPc+l3cN7+wuJlK6uz0YdJEOlQDbl6jo/YlPi4mb8agUkVC8BF7V8NuzeyPNqRksA3hztKQ==",
      "dev": true,
      "license": "MIT",
      "engines": {
        "node": ">= 0.8"
      }
    },
    "node_modules/utils-merge": {
      "version": "1.0.1",
      "resolved": "https://registry.npmjs.org/utils-merge/-/utils-merge-1.0.1.tgz",
      "integrity": "sha512-pMZTvIkT1d+TFGvDOqodOclx0QWkkgi6Tdoa8gC8ffGAAqz9pzPTZWAybbsHHoED/ztMtkv/VoYTYyShUn81hA==",
      "dev": true,
      "license": "MIT",
      "engines": {
        "node": ">= 0.4.0"
      }
    },
    "node_modules/vary": {
      "version": "1.1.2",
      "resolved": "https://registry.npmjs.org/vary/-/vary-1.1.2.tgz",
      "integrity": "sha512-BNGbWLfd0eUPabhkXUVm0j8uuvREyTh5ovRa/dyow/BqAbZJyC+5fU+IzQOzmAKzYqYRAISoRhdQr3eIZ/PXqg==",
      "dev": true,
      "license": "MIT",
      "engines": {
        "node": ">= 0.8"
      }
    },
    "node_modules/vite": {
      "version": "8.1.0",
      "resolved": "https://registry.npmjs.org/vite/-/vite-8.1.0.tgz",
      "integrity": "sha512-BuJcQK/56NQTWDGn4ABea3q4SSBdNPWwNZKTkkUpcMPnLoquSYH8llRtSUIgoL1KSCpHt5eghLShn50mH36y7Q==",
      "dev": true,
      "license": "MIT",
      "dependencies": {
        "lightningcss": "^1.32.0",
        "picomatch": "^4.0.4",
        "postcss": "^8.5.15",
        "rolldown": "~1.1.2",
        "tinyglobby": "^0.2.17"
      },
      "bin": {
        "vite": "bin/vite.js"
      },
      "engines": {
        "node": "^20.19.0 || >=22.12.0"
      },
      "funding": {
        "url": "https://github.com/vitejs/vite?sponsor=1"
      },
      "optionalDependencies": {
        "fsevents": "~2.3.3"
      },
      "peerDependencies": {
        "@types/node": "^20.19.0 || >=22.12.0",
        "@vitejs/devtools": "^0.3.0",
        "esbuild": "^0.27.0 || ^0.28.0",
        "jiti": ">=1.21.0",
        "less": "^4.0.0",
        "sass": "^1.70.0",
        "sass-embedded": "^1.70.0",
        "stylus": ">=0.54.8",
        "sugarss": "^5.0.0",
        "terser": "^5.16.0",
        "tsx": "^4.8.1",
        "yaml": "^2.4.2"
      },
      "peerDependenciesMeta": {
        "@types/node": {
          "optional": true
        },
        "@vitejs/devtools": {
          "optional": true
        },
        "esbuild": {
          "optional": true
        },
        "jiti": {
          "optional": true
        },
        "less": {
          "optional": true
        },
        "sass": {
          "optional": true
        },
        "sass-embedded": {
          "optional": true
        },
        "stylus": {
          "optional": true
        },
        "sugarss": {
          "optional": true
        },
        "terser": {
          "optional": true
        },
        "tsx": {
          "optional": true
        },
        "yaml": {
          "optional": true
        }
      }
    },
    "node_modules/vitest": {
      "version": "4.1.9",
      "resolved": "https://registry.npmjs.org/vitest/-/vitest-4.1.9.tgz",
      "integrity": "sha512-nE3/LEyc0z87uHYLZebqCUOaJr2hdtuPp7BQ4BosVFnfltxgAvMG08NyrSGlPpOUWvR27c5flSmYFTNr78L9GQ==",
      "dev": true,
      "license": "MIT",
      "dependencies": {
        "@vitest/expect": "4.1.9",
        "@vitest/mocker": "4.1.9",
        "@vitest/pretty-format": "4.1.9",
        "@vitest/runner": "4.1.9",
        "@vitest/snapshot": "4.1.9",
        "@vitest/spy": "4.1.9",
        "@vitest/utils": "4.1.9",
        "es-module-lexer": "^2.0.0",
        "expect-type": "^1.3.0",
        "magic-string": "^0.30.21",
        "obug": "^2.1.1",
        "pathe": "^2.0.3",
        "picomatch": "^4.0.3",
        "std-env": "^4.0.0-rc.1",
        "tinybench": "^2.9.0",
        "tinyexec": "^1.0.2",
        "tinyglobby": "^0.2.15",
        "tinyrainbow": "^3.1.0",
        "vite": "^6.0.0 || ^7.0.0 || ^8.0.0",
        "why-is-node-running": "^2.3.0"
      },
      "bin": {
        "vitest": "vitest.mjs"
      },
      "engines": {
        "node": "^20.0.0 || ^22.0.0 || >=24.0.0"
      },
      "funding": {
        "url": "https://opencollective.com/vitest"
      },
      "peerDependencies": {
        "@edge-runtime/vm": "*",
        "@opentelemetry/api": "^1.9.0",
        "@types/node": "^20.0.0 || ^22.0.0 || >=24.0.0",
        "@vitest/browser-playwright": "4.1.9",
        "@vitest/browser-preview": "4.1.9",
        "@vitest/browser-webdriverio": "4.1.9",
        "@vitest/coverage-istanbul": "4.1.9",
        "@vitest/coverage-v8": "4.1.9",
        "@vitest/ui": "4.1.9",
        "happy-dom": "*",
        "jsdom": "*",
        "vite": "^6.0.0 || ^7.0.0 || ^8.0.0"
      },
      "peerDependenciesMeta": {
        "@edge-runtime/vm": {
          "optional": true
        },
        "@opentelemetry/api": {
          "optional": true
        },
        "@types/node": {
          "optional": true
        },
        "@vitest/browser-playwright": {
          "optional": true
        },
        "@vitest/browser-preview": {
          "optional": true
        },
        "@vitest/browser-webdriverio": {
          "optional": true
        },
        "@vitest/coverage-istanbul": {
          "optional": true
        },
        "@vitest/coverage-v8": {
          "optional": true
        },
        "@vitest/ui": {
          "optional": true
        },
        "happy-dom": {
          "optional": true
        },
        "jsdom": {
          "optional": true
        },
        "vite": {
          "optional": false
        }
      }
    },
    "node_modules/why-is-node-running": {
      "version": "2.3.0",
      "resolved": "https://registry.npmjs.org/why-is-node-running/-/why-is-node-running-2.3.0.tgz",
      "integrity": "sha512-hUrmaWBdVDcxvYqnyh09zunKzROWjbZTiNy8dBEjkS7ehEDQibXJ7XvlmtbwuTclUiIyN+CyXQD4Vmko8fNm8w==",
      "dev": true,
      "license": "MIT",
      "dependencies": {
        "siginfo": "^2.0.0",
        "stackback": "0.0.2"
      },
      "bin": {
        "why-is-node-running": "cli.js"
      },
      "engines": {
        "node": ">=8"
      }
    },
    "node_modules/wrap-ansi": {
      "version": "9.0.2",
      "resolved": "https://registry.npmjs.org/wrap-ansi/-/wrap-ansi-9.0.2.tgz",
      "integrity": "sha512-42AtmgqjV+X1VpdOfyTGOYRi0/zsoLqtXQckTmqTeybT+BDIbM/Guxo7x3pE2vtpr1ok6xRqM9OpBe+Jyoqyww==",
      "dev": true,
      "license": "MIT",
      "dependencies": {
        "ansi-styles": "^6.2.1",
        "string-width": "^7.0.0",
        "strip-ansi": "^7.1.0"
      },
      "engines": {
        "node": ">=18"
      },
      "funding": {
        "url": "https://github.com/chalk/wrap-ansi?sponsor=1"
      }
    },
    "node_modules/wrappy": {
      "version": "1.0.2",
      "resolved": "https://registry.npmjs.org/wrappy/-/wrappy-1.0.2.tgz",
      "integrity": "sha512-l4Sp/DRseor9wL6EvV2+TuQn63dMkPjZ/sp9XkghTEbV9KlPS1xUsZ3u7/IQO4wxtcFB4bgpQPRcR3QCvezPcQ==",
      "dev": true,
      "license": "ISC"
    },
    "node_modules/ws": {
      "version": "8.21.0",
      "resolved": "https://registry.npmjs.org/ws/-/ws-8.21.0.tgz",
      "integrity": "sha512-Vsp28b7DRcimFQvrqu2Wek3z1iYxDCWqHYB8Qsnk/S4RfaCQzPGPyBNuVjJV3cd6UiKtUtp6sNM77gWvzcCH+g==",
      "license": "MIT",
      "engines": {
        "node": ">=10.0.0"
      },
      "peerDependencies": {
        "bufferutil": "^4.0.1",
        "utf-8-validate": ">=5.0.2"
      },
      "peerDependenciesMeta": {
        "bufferutil": {
          "optional": true
        },
        "utf-8-validate": {
          "optional": true
        }
      }
    },
    "node_modules/y18n": {
      "version": "5.0.8",
      "resolved": "https://registry.npmjs.org/y18n/-/y18n-5.0.8.tgz",
      "integrity": "sha512-0pfFzegeDWJHJIAmTLRP2DwHjdF5s7jo9tuztdQxAhINCdvS+3nGINqPd00AphqJR/0LhANUS6/+7SCb98YOfA==",
      "dev": true,
      "license": "ISC",
      "engines": {
        "node": ">=10"
      }
    },
    "node_modules/yargs": {
      "version": "18.0.0",
      "resolved": "https://registry.npmjs.org/yargs/-/yargs-18.0.0.tgz",
      "integrity": "sha512-4UEqdc2RYGHZc7Doyqkrqiln3p9X2DZVxaGbwhn2pi7MrRagKaOcIKe8L3OxYcbhXLgLFUS3zAYuQjKBQgmuNg==",
      "dev": true,
      "license": "MIT",
      "dependencies": {
        "cliui": "^9.0.1",
        "escalade": "^3.1.1",
        "get-caller-file": "^2.0.5",
        "string-width": "^7.2.0",
        "y18n": "^5.0.5",
        "yargs-parser": "^22.0.0"
      },
      "engines": {
        "node": "^20.19.0 || ^22.12.0 || >=23"
      }
    },
    "node_modules/yargs-parser": {
      "version": "22.0.0",
      "resolved": "https://registry.npmjs.org/yargs-parser/-/yargs-parser-22.0.0.tgz",
      "integrity": "sha512-rwu/ClNdSMpkSrUb+d6BRsSkLUq1fmfsY6TOpYzTwvwkg1/NRG85KBy3kq++A8LKQwX6lsu+aWad+2khvuXrqw==",
      "dev": true,
      "license": "ISC",
      "engines": {
        "node": "^20.19.0 || ^22.12.0 || >=23"
      }
    }
  }
}
QUALITY_REFACTOR_FILE

write_file 'package.json' <<'QUALITY_REFACTOR_FILE'
{
  "name": "slottr-app",
  "private": true,
  "version": "0.1.0",
  "type": "module",
  "scripts": {
    "dev": "vite",
    "build": "vite build",
    "preview": "vite preview",
    "server": "node scripts/server.mjs",
    "start": "node scripts/server.mjs",
    "dev:all": "concurrently \"npm run server\" \"npm run dev\"",
    "migrate": "node scripts/migrate-from-json.mjs",
    "seed:users": "node scripts/seed-users.mjs",
    "test": "vitest run",
    "test:watch": "vitest",
    "test:coverage": "vitest run --coverage"
  },
  "engines": {
    "node": ">=22"
  },
  "dependencies": {
    "@libsql/client": "^0.17.3",
    "bcryptjs": "^3.0.3",
    "react": "^18.3.1",
    "react-dom": "^18.3.1",
    "react-router-dom": "^6.26.0"
  },
  "devDependencies": {
    "@types/bcryptjs": "^2.4.6",
    "@types/react": "^19.2.17",
    "@types/react-dom": "^19.2.3",
    "@vitejs/plugin-react": "^6.0.3",
    "@vitest/coverage-v8": "^4.1.9",
    "concurrently": "^10.0.3",
    "cors": "^2.8.6",
    "express": "^4.22.2",
    "jsonwebtoken": "^9.0.3",
    "supertest": "^7.0.0",
    "typescript": "^6.0.3",
    "vite": "^8.1.0",
    "vitest": "^4.1.9"
  }
}
QUALITY_REFACTOR_FILE

write_file 'scripts/config.mjs' <<'QUALITY_REFACTOR_FILE'
export const PORT = Number(process.env.PORT || 3001)

if (!process.env.JWT_SECRET && process.env.NODE_ENV === 'production') {
  throw new Error('JWT_SECRET is required in production')
}

export const JWT_SECRET = process.env.JWT_SECRET || 'dev-secret-key'
export const HAS_CONFIGURED_JWT_SECRET = Boolean(process.env.JWT_SECRET)
export const JWT_EXPIRES_IN = '15m'
export const REFRESH_TTL_DAYS = 30
export const REFRESH_TTL_MS = REFRESH_TTL_DAYS * 24 * 60 * 60 * 1000
export const BCRYPT_ROUNDS = 10
export const MIN_NOTICE_MIN = 60

export const CORS_ORIGINS = (process.env.CORS_ORIGIN || '*')
  .split(',').map(s => s.trim()).filter(Boolean)
QUALITY_REFACTOR_FILE

write_file 'scripts/middleware/asyncRoute.mjs' <<'QUALITY_REFACTOR_FILE'
export const asyncRoute = (fn) => (req, res, next) =>
  Promise.resolve(fn(req, res, next)).catch(next)
QUALITY_REFACTOR_FILE

write_file 'scripts/middleware/authMiddleware.mjs' <<'QUALITY_REFACTOR_FILE'
import { parseToken } from '../auth.mjs'
import { JWT_SECRET } from '../config.mjs'

export function parseAuthHeader(req) {
  return parseToken(req.headers.authorization || '', JWT_SECRET)
}

export function requireAuth(req, res, next) {
  const user = parseAuthHeader(req)
  if (!user) return res.status(401).json({ error: 'Authentication required' })
  req.user = user
  next()
}
QUALITY_REFACTOR_FILE

write_file 'scripts/routes/authRoutes.mjs' <<'QUALITY_REFACTOR_FILE'
import bcrypt from 'bcryptjs'
import { hashRefresh } from '../auth.mjs'
import { BCRYPT_ROUNDS } from '../config.mjs'
import { dbGet, dbRun, rowToUser } from '../db.mjs'
import { asyncRoute } from '../middleware/asyncRoute.mjs'
import { consumeRefreshToken, issueAccessToken, issueRefreshToken } from '../services/tokenService.mjs'

const EMAIL_RE = /^[^\s@]+@[^\s@]+\.[^\s@]+$/

export function registerAuthRoutes(app) {
  app.post('/register', asyncRoute(async (req, res) => {
    const { email, password, name } = req.body || {}
    if (!email || !EMAIL_RE.test(String(email))) return res.status(400).json({ error: 'Valid email required' })
    if (!password || String(password).length < 6) return res.status(400).json({ error: 'Password must be at least 6 characters' })
    if (!name || !String(name).trim()) return res.status(400).json({ error: 'Name required' })

    const passwordHash = bcrypt.hashSync(String(password), BCRYPT_ROUNDS)
    let info
    try {
      info = await dbRun(
        'INSERT INTO users (email, passwordHash, name) VALUES (?, ?, ?)',
        [String(email).toLowerCase(), passwordHash, String(name).trim()],
      )
    } catch (e) {
      if (String(e.message).includes('UNIQUE')) return res.status(400).json({ error: 'Email already exists' })
      return res.status(500).json({ error: 'Could not create user' })
    }

    const user = rowToUser(await dbGet('SELECT * FROM users WHERE id = ?', [info.lastInsertRowid]))
    res.status(201).json({
      accessToken: issueAccessToken(user),
      refreshToken: await issueRefreshToken(user.id),
      user,
    })
  }))

  app.post('/login', asyncRoute(async (req, res) => {
    const { email, password } = req.body || {}
    if (!email || !password) return res.status(400).json({ error: 'Email and password required' })
    const row = await dbGet('SELECT * FROM users WHERE email = ?', [String(email).toLowerCase()])
    if (!row || !bcrypt.compareSync(String(password), row.passwordHash)) {
      return res.status(400).json({ error: 'Incorrect email or password' })
    }
    const user = rowToUser(row)
    res.json({
      accessToken: issueAccessToken(user),
      refreshToken: await issueRefreshToken(user.id),
      user,
    })
  }))

  app.post('/refresh', asyncRoute(async (req, res) => {
    const session = await consumeRefreshToken(req.body?.refreshToken)
    if (!session) return res.status(401).json({ error: 'Invalid or expired refresh token' })
    await dbRun('DELETE FROM refresh_tokens WHERE id = ?', [Number(session.tokenRow.id)])
    res.json({
      accessToken: issueAccessToken(session.user),
      refreshToken: await issueRefreshToken(session.user.id),
      user: session.user,
    })
  }))

  app.post('/logout', asyncRoute(async (req, res) => {
    const presented = req.body?.refreshToken
    if (presented) await dbRun('DELETE FROM refresh_tokens WHERE tokenHash = ?', [hashRefresh(presented)])
    res.json({ ok: true })
  }))
}
QUALITY_REFACTOR_FILE

write_file 'scripts/routes/availabilityRoutes.mjs' <<'QUALITY_REFACTOR_FILE'
import {
  DEFAULT_WORKING_HOURS,
  calculateSlots,
  dowKeyFromISO,
  hhmmToMin,
  normalizeWorkingHours,
} from '../availability.mjs'
import { MIN_NOTICE_MIN } from '../config.mjs'
import { dbAll, dbGet } from '../db.mjs'
import { requireAuth } from '../middleware/authMiddleware.mjs'
import { asyncRoute } from '../middleware/asyncRoute.mjs'

export function registerAvailabilityRoutes(app) {
  app.get('/availability/:providerId', requireAuth, asyncRoute(async (req, res) => {
    const providerId = Number(req.params.providerId)
    const dateISO = String(req.query.date || '')
    const duration = Number(req.query.duration) || 60

    if (!/^\d{4}-\d{2}-\d{2}$/.test(dateISO)) {
      return res.status(400).json({ error: 'date query param required as YYYY-MM-DD' })
    }
    const provider = await dbGet('SELECT * FROM users WHERE id = ?', [providerId])
    if (!provider) return res.status(404).json({ error: 'Provider not found' })

    const workingHours = normalizeWorkingHours(provider.workingHours ? JSON.parse(provider.workingHours) : undefined)
    const dayKey = dowKeyFromISO(dateISO)
    const hasOwn = Object.prototype.hasOwnProperty.call(workingHours, dayKey)
    const window = hasOwn ? workingHours[dayKey] : (DEFAULT_WORKING_HOURS[dayKey] || null)
    if (!window) return res.json({ slots: [], workingHours: null })

    const blockingRows = await dbAll(`
      SELECT time, endTime, durationMin FROM bookings
      WHERE providerId = ? AND dateISO = ? AND status != 'cancelled'
    `, [providerId, dateISO])
    const blocking = blockingRows.map(row => {
      const start = hhmmToMin(row.time)
      const end = row.endTime ? hhmmToMin(row.endTime) : start + (Number(row.durationMin) || 60)
      return [start, end]
    })

    const slots = calculateSlots({
      window,
      blocking,
      now: new Date(),
      dateISO,
      duration,
      minNoticeMin: MIN_NOTICE_MIN,
    })
    res.json({ slots, workingHours: window })
  }))
}
QUALITY_REFACTOR_FILE

write_file 'scripts/routes/bookingRoutes.mjs' <<'QUALITY_REFACTOR_FILE'
import { dbAll, dbGet, dbRun, rowToBooking } from '../db.mjs'
import { requireAuth } from '../middleware/authMiddleware.mjs'
import { asyncRoute } from '../middleware/asyncRoute.mjs'
import { pushNotification } from '../services/notificationService.mjs'

export function registerBookingRoutes(app) {
  app.get('/bookings', requireAuth, asyncRoute(async (req, res) => {
    const me = req.user.userId
    const rows = await dbAll(`
      SELECT * FROM bookings WHERE providerId = ? OR customerId = ? ORDER BY dateISO, time
    `, [me, me])
    res.json(rows.map(rowToBooking))
  }))

  app.get('/bookings/:id', requireAuth, asyncRoute(async (req, res) => {
    const row = await dbGet('SELECT * FROM bookings WHERE id = ?', [Number(req.params.id)])
    if (!row) return res.status(404).json({ error: 'Booking not found' })
    const me = req.user.userId
    if (Number(row.providerId) !== me && Number(row.customerId) !== me) {
      return res.status(403).json({ error: 'Forbidden' })
    }
    res.json(rowToBooking(row))
  }))

  app.post('/bookings', requireAuth, asyncRoute(async (req, res) => {
    const booking = req.body || {}
    const serviceId = Number(booking.serviceId)
    if (!serviceId) return res.status(400).json({ error: 'serviceId required' })

    const service = await dbGet('SELECT * FROM services WHERE id = ?', [serviceId])
    if (!service) return res.status(400).json({ error: 'Unknown serviceId' })
    if (Number(service.providerId) !== req.user.userId) {
      return res.status(403).json({ error: "Cannot book another user's service" })
    }

    const info = await dbRun(`
      INSERT INTO bookings (
        providerId, customerId, serviceId,
        dateISO, time, endTime, durationMin, service, total, status,
        withName, initials, customerEmail, customerPhone, notes
      ) VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)
    `, [
      Number(service.providerId), req.user.userId, serviceId,
      String(booking.dateISO || ''), String(booking.time || ''), booking.endTime || null,
      Number(booking.durationMin) || 60, String(booking.service || ''), Number(booking.total) || 0,
      String(booking.status || 'confirmed'), String(booking.withName || ''), String(booking.initials || ''),
      String(booking.customerEmail || ''), booking.customerPhone || null, booking.notes || null,
    ])
    const row = await dbGet('SELECT * FROM bookings WHERE id = ?', [info.lastInsertRowid])
    await pushNotification(req.user.userId, 'calendar', {
      service: row.service, withName: row.withName, dateISO: row.dateISO, time: row.time,
    }, 'accent')
    res.status(201).json(rowToBooking(row))
  }))

  app.patch('/bookings/:id', requireAuth, asyncRoute(async (req, res) => {
    const id = Number(req.params.id)
    const existing = await dbGet('SELECT * FROM bookings WHERE id = ?', [id])
    if (!existing) return res.status(404).json({ error: 'Booking not found' })
    if (Number(existing.providerId) !== req.user.userId) {
      return res.status(403).json({ error: 'Only the provider can modify this booking' })
    }

    const allowed = ['dateISO', 'time', 'endTime', 'durationMin', 'status',
      'withName', 'initials', 'customerEmail', 'customerPhone', 'notes', 'service', 'total']
    const sets = []
    const values = []
    for (const key of allowed) {
      if (!(key in (req.body || {}))) continue
      sets.push(`${key} = ?`)
      values.push(req.body[key])
    }
    if (sets.length) {
      values.push(id)
      await dbRun(`UPDATE bookings SET ${sets.join(', ')} WHERE id = ?`, values)
    }
    const updated = await dbGet('SELECT * FROM bookings WHERE id = ?', [id])

    if (updated.status === 'cancelled' && existing.status !== 'cancelled') {
      await pushNotification(req.user.userId, 'close', {
        service: updated.service, dateISO: updated.dateISO, time: updated.time,
      }, 'danger')
    } else if (updated.time !== existing.time || updated.dateISO !== existing.dateISO) {
      await pushNotification(req.user.userId, 'clock', {
        service: updated.service, dateISO: updated.dateISO, time: updated.time,
      }, 'accent')
    }
    res.json(rowToBooking(updated))
  }))

  app.delete('/bookings/:id', requireAuth, asyncRoute(async (req, res) => {
    const id = Number(req.params.id)
    const existing = await dbGet('SELECT * FROM bookings WHERE id = ?', [id])
    if (!existing) return res.status(404).json({ error: 'Booking not found' })
    if (Number(existing.providerId) !== req.user.userId) {
      return res.status(403).json({ error: 'Only the provider can delete this booking' })
    }
    await dbRun('DELETE FROM bookings WHERE id = ?', [id])
    res.status(204).end()
  }))
}
QUALITY_REFACTOR_FILE

write_file 'scripts/routes/notificationRoutes.mjs' <<'QUALITY_REFACTOR_FILE'
import { dbAll, dbGet, dbRun, rowToNotification } from '../db.mjs'
import { requireAuth } from '../middleware/authMiddleware.mjs'
import { asyncRoute } from '../middleware/asyncRoute.mjs'

export function registerNotificationRoutes(app) {
  app.get('/notifications', requireAuth, asyncRoute(async (req, res) => {
    const rows = await dbAll(`
      SELECT * FROM notifications WHERE userId = ? ORDER BY createdAt DESC
    `, [req.user.userId])
    res.json(rows.map(rowToNotification))
  }))

  app.patch('/notifications/:id', requireAuth, asyncRoute(async (req, res) => {
    const id = Number(req.params.id)
    const row = await dbGet('SELECT * FROM notifications WHERE id = ?', [id])
    if (!row) return res.status(404).json({ error: 'Notification not found' })
    if (Number(row.userId) !== req.user.userId) return res.status(403).json({ error: 'Not the owner' })
    if (typeof req.body?.unread === 'boolean') {
      await dbRun('UPDATE notifications SET unread = ? WHERE id = ?', [req.body.unread ? 1 : 0, id])
    }
    const updated = await dbGet('SELECT * FROM notifications WHERE id = ?', [id])
    res.json(rowToNotification(updated))
  }))

  app.post('/notifications/mark-all-read', requireAuth, asyncRoute(async (req, res) => {
    await dbRun('UPDATE notifications SET unread = 0 WHERE userId = ? AND unread = 1', [req.user.userId])
    res.json({ ok: true })
  }))

  app.delete('/notifications/:id', requireAuth, asyncRoute(async (req, res) => {
    const id = Number(req.params.id)
    const row = await dbGet('SELECT * FROM notifications WHERE id = ?', [id])
    if (!row) return res.status(404).json({ error: 'Notification not found' })
    if (Number(row.userId) !== req.user.userId) return res.status(403).json({ error: 'Not the owner' })
    await dbRun('DELETE FROM notifications WHERE id = ?', [id])
    res.status(204).end()
  }))
}
QUALITY_REFACTOR_FILE

write_file 'scripts/routes/serviceRoutes.mjs' <<'QUALITY_REFACTOR_FILE'
import { dbAll, dbGet, dbRun, rowToService } from '../db.mjs'
import { requireAuth } from '../middleware/authMiddleware.mjs'
import { asyncRoute } from '../middleware/asyncRoute.mjs'

export function validateServicePayload(body) {
  const errs = []
  if (!body || typeof body !== 'object') return ['payload required']
  if (!body.tag || typeof body.tag !== 'object') errs.push('tag required')
  if (!body.name || typeof body.name !== 'object') errs.push('name required')
  if (!body.description || typeof body.description !== 'object') errs.push('description required')
  if (!Number.isFinite(Number(body.duration)) || Number(body.duration) <= 0) errs.push('duration must be > 0')
  if (!Number.isFinite(Number(body.price)) || Number(body.price) < 0) errs.push('price must be >= 0')
  return errs
}

export function registerServiceRoutes(app) {
  app.get('/services', requireAuth, asyncRoute(async (req, res) => {
    const rows = await dbAll('SELECT * FROM services WHERE providerId = ? ORDER BY id', [req.user.userId])
    res.json(rows.map(rowToService))
  }))

  app.get('/services/:id', requireAuth, asyncRoute(async (req, res) => {
    const row = await dbGet('SELECT * FROM services WHERE id = ?', [Number(req.params.id)])
    if (!row) return res.status(404).json({ error: 'Service not found' })
    if (Number(row.providerId) !== req.user.userId) return res.status(403).json({ error: 'Not the owner' })
    res.json(rowToService(row))
  }))

  app.post('/services', requireAuth, asyncRoute(async (req, res) => {
    const errs = validateServicePayload(req.body)
    if (errs.length) return res.status(400).json({ error: errs.join('; ') })
    const info = await dbRun(`
      INSERT INTO services (providerId, tag, tone, duration, price, name, description)
      VALUES (?, ?, ?, ?, ?, ?, ?)
    `, [
      req.user.userId,
      JSON.stringify(req.body.tag),
      String(req.body.tone || 'muted'),
      Number(req.body.duration),
      Number(req.body.price),
      JSON.stringify(req.body.name),
      JSON.stringify(req.body.description),
    ])
    const row = await dbGet('SELECT * FROM services WHERE id = ?', [info.lastInsertRowid])
    res.status(201).json(rowToService(row))
  }))

  app.patch('/services/:id', requireAuth, asyncRoute(async (req, res) => {
    const id = Number(req.params.id)
    const existing = await dbGet('SELECT * FROM services WHERE id = ?', [id])
    if (!existing) return res.status(404).json({ error: 'Service not found' })
    if (Number(existing.providerId) !== req.user.userId) return res.status(403).json({ error: 'Not the owner' })

    const allowed = ['tag', 'tone', 'duration', 'price', 'name', 'description']
    const sets = []
    const values = []
    for (const key of allowed) {
      if (!(key in (req.body || {}))) continue
      sets.push(`${key} = ?`)
      values.push(['tag', 'name', 'description'].includes(key) ? JSON.stringify(req.body[key]) : req.body[key])
    }
    if (sets.length) {
      values.push(id)
      await dbRun(`UPDATE services SET ${sets.join(', ')} WHERE id = ?`, values)
    }
    const updated = await dbGet('SELECT * FROM services WHERE id = ?', [id])
    res.json(rowToService(updated))
  }))

  app.delete('/services/:id', requireAuth, asyncRoute(async (req, res) => {
    const id = Number(req.params.id)
    const existing = await dbGet('SELECT * FROM services WHERE id = ?', [id])
    if (!existing) return res.status(404).json({ error: 'Service not found' })
    if (Number(existing.providerId) !== req.user.userId) return res.status(403).json({ error: 'Not the owner' })
    await dbRun('DELETE FROM services WHERE id = ?', [id])
    res.status(204).end()
  }))
}
QUALITY_REFACTOR_FILE

write_file 'scripts/routes/userRoutes.mjs' <<'QUALITY_REFACTOR_FILE'
import { dbGet, dbRun, rowToUser } from '../db.mjs'
import { requireAuth } from '../middleware/authMiddleware.mjs'
import { asyncRoute } from '../middleware/asyncRoute.mjs'

export function registerUserRoutes(app) {
  app.get('/users/:id', requireAuth, asyncRoute(async (req, res) => {
    const id = Number(req.params.id)
    if (id !== req.user.userId) return res.status(403).json({ error: 'Forbidden' })
    const row = await dbGet('SELECT * FROM users WHERE id = ?', [id])
    if (!row) return res.status(404).json({ error: 'User not found' })
    res.json(rowToUser(row))
  }))

  app.patch('/users/:id', requireAuth, asyncRoute(async (req, res) => {
    const id = Number(req.params.id)
    if (id !== req.user.userId) return res.status(403).json({ error: 'Forbidden' })
    const allowed = ['name', 'displayName', 'phone', 'timezone', 'bio', 'workingHours']
    const sets = []
    const values = []
    for (const key of allowed) {
      if (!(key in (req.body || {}))) continue
      sets.push(`${key} = ?`)
      const value = req.body[key]
      values.push(key === 'workingHours' && value !== null ? JSON.stringify(value) : value)
    }
    if (sets.length) {
      values.push(id)
      await dbRun(`UPDATE users SET ${sets.join(', ')} WHERE id = ?`, values)
    }
    const row = await dbGet('SELECT * FROM users WHERE id = ?', [id])
    res.json(rowToUser(row))
  }))
}
QUALITY_REFACTOR_FILE

write_file 'scripts/server.mjs' <<'QUALITY_REFACTOR_FILE'
// Custom Express server — libSQL (Turso / local file) + JWT with refresh rotation.
//
// Endpoints are registered from ./routes/* so this file stays focused on
// application wiring: middleware, route registration, error handling and boot.

import express from 'express'
import cors from 'cors'
import { fileURLToPath } from 'node:url'
import {
  CORS_ORIGINS,
  HAS_CONFIGURED_JWT_SECRET,
  JWT_EXPIRES_IN,
  PORT,
} from './config.mjs'
import { registerAuthRoutes } from './routes/authRoutes.mjs'
import { registerUserRoutes } from './routes/userRoutes.mjs'
import { registerServiceRoutes, validateServicePayload } from './routes/serviceRoutes.mjs'
import { registerBookingRoutes } from './routes/bookingRoutes.mjs'
import { registerAvailabilityRoutes } from './routes/availabilityRoutes.mjs'
import { registerNotificationRoutes } from './routes/notificationRoutes.mjs'
import { purgeExpiredRefreshTokens } from './services/tokenService.mjs'

export { validateServicePayload }

export const app = express()

app.use(cors({
  origin: CORS_ORIGINS.includes('*') ? true : CORS_ORIGINS,
  credentials: false,
}))
app.use(express.json())

app.get('/healthz', (_req, res) => res.json({ ok: true }))

registerAuthRoutes(app)
registerUserRoutes(app)
registerServiceRoutes(app)
registerBookingRoutes(app)
registerAvailabilityRoutes(app)
registerNotificationRoutes(app)

purgeExpiredRefreshTokens().catch(() => { /* ignore startup error */ })
setInterval(() => { purgeExpiredRefreshTokens().catch(() => {}) }, 24 * 60 * 60 * 1000).unref()

// eslint-disable-next-line no-unused-vars
app.use((err, req, res, _next) => {
  console.error('[error]', err)
  res.status(500).json({ error: 'Internal server error' })
})

export function startServer(port = PORT) {
  const dbInfo = process.env.TURSO_DATABASE_URL ? 'Turso (remote)' : 'local file ./slottr.db'
  console.log(` {^_^}/ Slottr API on port ${port}`)
  console.log(` DB: ${dbInfo}`)
  console.log(` CORS: ${CORS_ORIGINS.join(', ')}`)
  console.log(` JWT: HS256, exp ${JWT_EXPIRES_IN}${HAS_CONFIGURED_JWT_SECRET ? '' : ' (dev secret — set JWT_SECRET in prod!)'}`)
  return app.listen(port)
}

const isMain = process.argv[1] && process.argv[1] === fileURLToPath(import.meta.url)
if (isMain) startServer()
QUALITY_REFACTOR_FILE

write_file 'scripts/services/notificationService.mjs' <<'QUALITY_REFACTOR_FILE'
import { dbRun } from '../db.mjs'

export async function pushNotification(userId, kind, params, tone) {
  await dbRun(`
    INSERT INTO notifications (userId, kind, tone, params, unread)
    VALUES (?, ?, ?, ?, 1)
  `, [userId, kind, tone || 'muted', JSON.stringify(params || {})])
}
QUALITY_REFACTOR_FILE

write_file 'scripts/services/tokenService.mjs' <<'QUALITY_REFACTOR_FILE'
import { randomBytes } from 'node:crypto'
import { signAccessToken, hashRefresh } from '../auth.mjs'
import { dbGet, dbRun, rowToUser } from '../db.mjs'
import { JWT_SECRET, JWT_EXPIRES_IN, REFRESH_TTL_MS } from '../config.mjs'

export function issueAccessToken(user) {
  return signAccessToken(user, JWT_SECRET, JWT_EXPIRES_IN)
}

export async function issueRefreshToken(userId) {
  const plain = randomBytes(48).toString('base64url')
  const tokenHash = hashRefresh(plain)
  const expiresAt = new Date(Date.now() + REFRESH_TTL_MS).toISOString()
  await dbRun(
    'INSERT INTO refresh_tokens (userId, tokenHash, expiresAt) VALUES (?, ?, ?)',
    [userId, tokenHash, expiresAt],
  )
  return plain
}

export async function consumeRefreshToken(plain) {
  if (!plain || typeof plain !== 'string') return null
  const tokenHash = hashRefresh(plain)
  const row = await dbGet('SELECT * FROM refresh_tokens WHERE tokenHash = ?', [tokenHash])
  if (!row) return null

  if (new Date(row.expiresAt).getTime() < Date.now()) {
    await dbRun('DELETE FROM refresh_tokens WHERE id = ?', [Number(row.id)])
    return null
  }

  const userRow = await dbGet('SELECT * FROM users WHERE id = ?', [Number(row.userId)])
  if (!userRow) return null
  return { user: rowToUser(userRow), tokenRow: row }
}

export async function purgeExpiredRefreshTokens() {
  await dbRun('DELETE FROM refresh_tokens WHERE expiresAt < ?', [new Date().toISOString()])
}
QUALITY_REFACTOR_FILE

write_file 'src/components/CommandPalette.tsx' <<'QUALITY_REFACTOR_FILE'
// Global command palette (⌘K / Ctrl+K).
// Searches services + bookings, keyboard navigation, jumps to detail pages.
//
// Usage:
//   <CommandPaletteProvider>
//     <App />
//   </CommandPaletteProvider>
//
//   const { open } = useCommandPalette()
//   open()  // programmatically

import { createContext, useCallback, useContext, useMemo, useState, type ReactNode } from 'react'
import Palette from './command-palette/Palette'
import { useGlobalCommandShortcut } from './command-palette/useGlobalCommandShortcut'
import type { CommandPaletteContextValue } from './command-palette/commandPaletteTypes'

const CommandPaletteContext = createContext<CommandPaletteContextValue | null>(null)

export function CommandPaletteProvider({ children }: { children: ReactNode }) {
  const [isOpen, setOpen] = useState(false)

  const open = useCallback(() => setOpen(true), [])
  const close = useCallback(() => setOpen(false), [])

  useGlobalCommandShortcut(open)

  const value = useMemo<CommandPaletteContextValue>(() => ({ open, close }), [open, close])

  return (
    <CommandPaletteContext.Provider value={value}>
      {children}
      {isOpen && <Palette onClose={close} />}
    </CommandPaletteContext.Provider>
  )
}

export function useCommandPalette(): CommandPaletteContextValue {
  const ctx = useContext(CommandPaletteContext)
  if (!ctx) throw new Error('useCommandPalette must be used inside <CommandPaletteProvider>')
  return ctx
}
QUALITY_REFACTOR_FILE

write_file 'src/components/SearchBox.tsx' <<'QUALITY_REFACTOR_FILE'
import { IconSearch } from './Icons'

interface SearchBoxProps {
  value: string
  placeholder: string
  onChange: (value: string) => void
  className?: string
}

export default function SearchBox({ value, placeholder, onChange, className = 'mb-6' }: SearchBoxProps) {
  return (
    <div
      className={className}
      style={{
        background: 'var(--bg-elev-1)',
        border: '1px solid var(--border)',
        borderRadius: 'var(--r-md)',
        padding: 'var(--s-2) var(--s-3)',
        display: 'flex', alignItems: 'center', gap: 'var(--s-2)',
        maxWidth: 420,
      }}
    >
      <IconSearch style={{ color: 'var(--text-muted)' }} />
      <input
        type="search"
        value={value}
        onChange={(e) => onChange(e.target.value)}
        placeholder={placeholder}
        style={{
          flex: 1, border: 'none', outline: 'none', background: 'none',
          color: 'var(--text)', fontSize: 13,
        }}
      />
    </div>
  )
}
QUALITY_REFACTOR_FILE

write_file 'src/components/ServiceForm.tsx' <<'QUALITY_REFACTOR_FILE'
import { useState, type ChangeEvent, type FormEvent } from 'react'
import { Button } from './UI'
import { useT } from '../i18n/SettingsContext'
import type { Service, ServicePayload } from '../types'
import ServiceBasicsFields from './service-form/ServiceBasicsFields'
import ServiceDetailsFields from './service-form/ServiceDetailsFields'
import type { ServiceFormErrors, ServiceFormTouched, ServiceFormValues } from './service-form/serviceFormTypes'
import { toServiceFormValues, toServicePayload, validateServiceForm } from './service-form/serviceFormUtils'

interface ServiceFormProps {
  service: Service | null
  onSubmit: (payload: ServicePayload) => void
  onCancel: () => void
  saving?: boolean
}

export default function ServiceForm({ service, onSubmit, onCancel, saving = false }: ServiceFormProps) {
  const t = useT()
  const [values, setValues] = useState<ServiceFormValues>(() => toServiceFormValues(service))
  const [errors, setErrors] = useState<ServiceFormErrors>({})
  const [touched, setTouched] = useState<ServiceFormTouched>({})

  const setField = (key: keyof ServiceFormValues) =>
    (e: ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
      const value = e.target.value
      setValues(prev => {
        const next = { ...prev, [key]: value }
        if (touched[key] || errors[key]) setErrors(validateServiceForm(next, t))
        return next
      })
    }

  const markTouched = (key: keyof ServiceFormValues) => () => {
    setTouched(prev => ({ ...prev, [key]: true }))
    setErrors(validateServiceForm(values, t))
  }

  const submit = (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    const nextErrors = validateServiceForm(values, t)
    setErrors(nextErrors)
    setTouched({
      tagEn: true, tagRu: true, nameEn: true, nameRu: true,
      descEn: true, descRu: true, duration: true, price: true,
    })
    if (Object.keys(nextErrors).length === 0) onSubmit(toServicePayload(values))
  }

  return (
    <form onSubmit={submit} noValidate>
      <ServiceBasicsFields
        values={values}
        errors={errors}
        setField={setField}
        markTouched={markTouched}
      />

      <ServiceDetailsFields
        values={values}
        errors={errors}
        setField={setField}
        markTouched={markTouched}
      />

      <div className="flex flex-gap-3 mt-4" style={{ justifyContent: 'flex-end' }}>
        <Button variant="ghost" type="button" onClick={onCancel} disabled={saving}>{t('common.cancel')}</Button>
        <Button type="submit" disabled={saving}>
          {saving ? t('common.loading') : (service ? t('common.save') : t('serviceForm.create'))}
        </Button>
      </div>
    </form>
  )
}
QUALITY_REFACTOR_FILE

write_file 'src/components/auth/AuthShell.tsx' <<'QUALITY_REFACTOR_FILE'
import type { ReactNode } from 'react'
import { Link } from 'react-router-dom'
import { LangToggle, ThemeToggle } from '../Toggles'

interface AuthShellProps {
  title: ReactNode
  subtitle: ReactNode
  footer: ReactNode
  children: ReactNode
}

export default function AuthShell({ title, subtitle, footer, children }: AuthShellProps) {
  return (
    <div className="auth">
      <div style={{ position: 'fixed', top: 16, right: 16, display: 'flex', gap: 8 }}>
        <LangToggle />
        <ThemeToggle />
      </div>

      <div className="auth-card">
        <Link to="/" className="flex flex-gap-3 mb-8" style={{ alignItems: 'center', fontWeight: 700, fontSize: 16 }}>
          <span style={{ width: 28, height: 28, borderRadius: 7, background: 'var(--accent)', display: 'grid', placeItems: 'center', color: '#fff', fontWeight: 800 }}>S</span>
          Slottr
        </Link>

        <h1 className="mb-2" style={{ fontSize: 28 }}>{title}</h1>
        <p className="subtitle mb-8">{subtitle}</p>

        {children}

        <p className="text-muted mt-8" style={{ textAlign: 'center', fontSize: 13 }}>
          {footer}
        </p>
      </div>
    </div>
  )
}
QUALITY_REFACTOR_FILE

write_file 'src/components/command-palette/CommandResults.tsx' <<'QUALITY_REFACTOR_FILE'
import type { ReactNode } from 'react'
import { SkeletonList } from '../Skeleton'
import { useT } from '../../i18n/SettingsContext'
import type { ResultItem } from './commandPaletteTypes'
import { splitResultGroups } from './commandPaletteUtils'

interface CommandResultsProps {
  query: string
  loading: boolean
  results: ResultItem[]
  activeIdx: number
  onPick: (item: ResultItem) => void
  onHover: (idx: number) => void
}

export default function CommandResults({
  query,
  loading,
  results,
  activeIdx,
  onPick,
  onHover,
}: CommandResultsProps) {
  const t = useT()
  const { serviceItems, bookingItems } = splitResultGroups(results)

  return (
    <div style={{ overflowY: 'auto', flex: 1, padding: 'var(--s-2) 0' }}>
      {loading && query && <SkeletonList count={4} />}

      {!loading && !query && (
        <div className="empty" style={{ padding: 'var(--s-8)' }}>{t('palette.empty.start')}</div>
      )}

      {!loading && query && results.length === 0 && (
        <div className="empty" style={{ padding: 'var(--s-8)' }}>{t('palette.empty.noResults')}</div>
      )}

      {results.length > 0 && (
        <>
          {serviceItems.length > 0 && (
            <Group title={t('palette.group.services')}>
              {serviceItems.map((item) => {
                const idx = results.indexOf(item)
                return (
                  <ResultRow
                    key={item.id}
                    item={item}
                    active={idx === activeIdx}
                    onClick={() => onPick(item)}
                    onHover={() => onHover(idx)}
                  />
                )
              })}
            </Group>
          )}

          {bookingItems.length > 0 && (
            <Group title={t('palette.group.bookings')}>
              {bookingItems.map((item) => {
                const idx = results.indexOf(item)
                return (
                  <ResultRow
                    key={item.id}
                    item={item}
                    active={idx === activeIdx}
                    onClick={() => onPick(item)}
                    onHover={() => onHover(idx)}
                  />
                )
              })}
            </Group>
          )}
        </>
      )}
    </div>
  )
}

function Group({ title, children }: { title: ReactNode; children: ReactNode }) {
  return (
    <div style={{ marginBottom: 'var(--s-2)' }}>
      <div style={{
        padding: 'var(--s-2) var(--s-5)',
        fontFamily: 'var(--font-mono)',
        fontSize: 11,
        color: 'var(--text-subtle)',
        textTransform: 'uppercase',
        letterSpacing: '0.06em',
      }}>{title}</div>
      {children}
    </div>
  )
}

function ResultRow({
  item, active, onClick, onHover,
}: {
  item: ResultItem
  active: boolean
  onClick: () => void
  onHover: () => void
}) {
  return (
    <button
      type="button"
      onClick={onClick}
      onMouseEnter={onHover}
      style={{
        display: 'block', width: '100%', textAlign: 'left',
        padding: 'var(--s-3) var(--s-5)',
        background: active ? 'var(--bg-hover)' : 'transparent',
        color: 'var(--text)',
        cursor: 'pointer',
        borderLeft: `2px solid ${active ? 'var(--accent)' : 'transparent'}`,
      }}
    >
      <div style={{ fontWeight: 500, fontSize: 14 }}>{item.title}</div>
      <div style={{ fontSize: 12, color: 'var(--text-muted)', marginTop: 2 }}>{item.subtitle}</div>
    </button>
  )
}
QUALITY_REFACTOR_FILE

write_file 'src/components/command-palette/Palette.tsx' <<'QUALITY_REFACTOR_FILE'
import { useCallback, useEffect, useMemo, useRef, useState, type ReactNode } from 'react'
import { useNavigate } from 'react-router-dom'
import { IconSearch } from '../Icons'
import { useT, useSettings } from '../../i18n/SettingsContext'
import CommandResults from './CommandResults'
import { buildPaletteResults } from './commandPaletteUtils'
import type { ResultItem } from './commandPaletteTypes'
import { useBodyScrollLock } from './useBodyScrollLock'
import { usePaletteData } from './usePaletteData'

interface PaletteProps {
  onClose: () => void
}

export default function Palette({ onClose }: PaletteProps) {
  const navigate = useNavigate()
  const t = useT()
  const { lang } = useSettings()
  const inputRef = useRef<HTMLInputElement | null>(null)

  const [query, setQuery] = useState('')
  const [activeIdx, setActiveIdx] = useState(0)
  const { services, bookings, loading } = usePaletteData()

  useBodyScrollLock()

  // Auto-focus input on mount.
  useEffect(() => {
    inputRef.current?.focus()
  }, [])

  const results = useMemo<ResultItem[]>(
    () => buildPaletteResults({ query, services, bookings, lang, t }),
    [query, services, bookings, lang, t],
  )

  // Reset active index when results change.
  useEffect(() => { setActiveIdx(0) }, [results])

  const goTo = useCallback((to: string) => {
    onClose()
    navigate(to)
  }, [navigate, onClose])

  const pickItem = useCallback((item: ResultItem) => {
    goTo(item.to)
  }, [goTo])

  const onKeyDown = (e: React.KeyboardEvent) => {
    if (e.key === 'Escape') { e.preventDefault(); onClose(); return }
    if (results.length === 0) return

    if (e.key === 'ArrowDown') {
      e.preventDefault()
      setActiveIdx(i => (i + 1) % results.length)
    } else if (e.key === 'ArrowUp') {
      e.preventDefault()
      setActiveIdx(i => (i - 1 + results.length) % results.length)
    } else if (e.key === 'Enter') {
      e.preventDefault()
      const item = results[activeIdx]
      if (item) pickItem(item)
    }
  }

  return (
    <div
      onMouseDown={(e) => { if (e.target === e.currentTarget) onClose() }}
      style={{
        position: 'fixed', inset: 0, zIndex: 150,
        background: 'rgba(0,0,0,0.5)',
        display: 'flex', justifyContent: 'center',
        padding: '15vh var(--s-4) var(--s-4)',
      }}
    >
      <div
        role="dialog"
        aria-modal="true"
        aria-label="Command palette"
        onKeyDown={onKeyDown}
        style={{
          width: '100%', maxWidth: 600, maxHeight: '70vh',
          background: 'var(--bg-elev-1)',
          border: '1px solid var(--border)',
          borderRadius: 'var(--r-lg)',
          boxShadow: 'var(--shadow-md)',
          display: 'flex', flexDirection: 'column',
          overflow: 'hidden',
        }}
      >
        <div style={{
          display: 'flex', alignItems: 'center', gap: 'var(--s-3)',
          padding: 'var(--s-4) var(--s-5)',
          borderBottom: '1px solid var(--border)',
        }}>
          <IconSearch style={{ color: 'var(--text-muted)' }} />
          <input
            ref={inputRef}
            type="search"
            value={query}
            onChange={(e) => setQuery(e.target.value)}
            placeholder={t('palette.placeholder')}
            style={{
              flex: 1, border: 'none', outline: 'none', background: 'none',
              color: 'var(--text)', fontSize: 15,
            }}
          />
        </div>

        <CommandResults
          query={query}
          loading={loading}
          results={results}
          activeIdx={activeIdx}
          onPick={pickItem}
          onHover={setActiveIdx}
        />

        <PaletteFooter />
      </div>
    </div>
  )
}

function PaletteFooter() {
  const t = useT()

  return (
    <div style={{
      display: 'flex', gap: 'var(--s-4)', justifyContent: 'flex-end',
      padding: 'var(--s-3) var(--s-5)',
      borderTop: '1px solid var(--border)',
      fontSize: 11, color: 'var(--text-subtle)',
    }}>
      <span><Kbd>↑↓</Kbd> {t('palette.hint.navigate')}</span>
      <span><Kbd>↵</Kbd> {t('palette.hint.select')}</span>
      <span><Kbd>Esc</Kbd> {t('palette.hint.close')}</span>
    </div>
  )
}

function Kbd({ children }: { children: ReactNode }) {
  return (
    <span style={{
      fontFamily: 'var(--font-mono)',
      background: 'var(--bg-elev-2)',
      padding: '1px 5px',
      borderRadius: 4,
      border: '1px solid var(--border)',
      marginRight: 4,
    }}>{children}</span>
  )
}
QUALITY_REFACTOR_FILE

write_file 'src/components/command-palette/commandPaletteTypes.ts' <<'QUALITY_REFACTOR_FILE'
export interface CommandPaletteContextValue {
  open: () => void
  close: () => void
}

export interface ResultItem {
  id: string
  group: 'services' | 'bookings'
  title: string
  subtitle: string
  to: string
}
QUALITY_REFACTOR_FILE

write_file 'src/components/command-palette/commandPaletteUtils.ts' <<'QUALITY_REFACTOR_FILE'
import { loc } from '../../data/mock'
import type { Booking, Lang, Service } from '../../types'
import type { TKey } from '../../i18n/translations'
import type { ResultItem } from './commandPaletteTypes'

type TFn = (key: TKey, params?: Record<string, string | number>) => string

export function isTypingTarget(target: EventTarget | null): boolean {
  if (!(target instanceof HTMLElement)) return false
  return /^(INPUT|TEXTAREA)$/.test(target.tagName)
}

export function isCommandK(e: KeyboardEvent): boolean {
  const isMac = navigator.platform.toUpperCase().includes('MAC')
  const cmd = isMac ? e.metaKey : e.ctrlKey
  return cmd && e.key.toLowerCase() === 'k'
}

export function buildPaletteResults({
  query,
  services,
  bookings,
  lang,
  t,
}: {
  query: string
  services: Service[]
  bookings: Booking[]
  lang: Lang
  t: TFn
}): ResultItem[] {
  if (!query.trim()) return []

  const q = query.toLowerCase()
  const items: ResultItem[] = []

  for (const s of services) {
    const haystack = [
      loc(s.name, lang), loc(s.description, lang), loc(s.tag, lang),
      s.name?.en, s.name?.ru, s.tag?.en, s.tag?.ru,
    ].filter(Boolean).join(' ').toLowerCase()

    if (haystack.includes(q)) {
      items.push({
        id: `service-${s.id}`,
        group: 'services',
        title: loc(s.name, lang),
        subtitle: `${loc(s.tag, lang)} · ${s.duration} ${t('services.minutes')} · $${s.price}`,
        to: `/services/${s.id}`,
      })
    }
  }

  for (const b of bookings) {
    const haystack = [
      b.service, b.withName, b.customerEmail, b.customerPhone, b.notes, b.dateISO, b.time,
    ].filter(Boolean).join(' ').toLowerCase()

    if (haystack.includes(q)) {
      items.push({
        id: `booking-${b.id}`,
        group: 'bookings',
        title: `${b.service} — ${b.withName || '—'}`,
        subtitle: `${b.dateISO} · ${b.time}${b.endTime ? `–${b.endTime}` : ''} · ${b.customerEmail}`,
        to: `/bookings/${b.id}`,
      })
    }
  }

  return items.slice(0, 20)
}

export function splitResultGroups(results: ResultItem[]): {
  serviceItems: ResultItem[]
  bookingItems: ResultItem[]
} {
  return {
    serviceItems: results.filter(r => r.group === 'services'),
    bookingItems: results.filter(r => r.group === 'bookings'),
  }
}
QUALITY_REFACTOR_FILE

write_file 'src/components/command-palette/useBodyScrollLock.ts' <<'QUALITY_REFACTOR_FILE'
import { useEffect } from 'react'

export function useBodyScrollLock(): void {
  useEffect(() => {
    const prevFocused = document.activeElement
    document.body.style.overflow = 'hidden'

    return () => {
      document.body.style.overflow = ''
      if (prevFocused instanceof HTMLElement) prevFocused.focus()
    }
  }, [])
}
QUALITY_REFACTOR_FILE

write_file 'src/components/command-palette/useGlobalCommandShortcut.ts' <<'QUALITY_REFACTOR_FILE'
import { useEffect } from 'react'
import { isCommandK, isTypingTarget } from './commandPaletteUtils'

export function useGlobalCommandShortcut(onOpen: () => void): void {
  useEffect(() => {
    const onKey = (e: KeyboardEvent) => {
      if (!isCommandK(e)) return
      // Don't hijack if user is typing in an input/textarea.
      if (isTypingTarget(e.target)) return
      e.preventDefault()
      onOpen()
    }

    window.addEventListener('keydown', onKey)
    return () => window.removeEventListener('keydown', onKey)
  }, [onOpen])
}
QUALITY_REFACTOR_FILE

write_file 'src/components/command-palette/usePaletteData.ts' <<'QUALITY_REFACTOR_FILE'
import { useEffect, useState } from 'react'
import { listBookings } from '../../data/bookingsApi'
import { listServices } from '../../data/servicesApi'
import type { Booking, Service } from '../../types'

export function usePaletteData(): {
  services: Service[]
  bookings: Booking[]
  loading: boolean
} {
  const [services, setServices] = useState<Service[]>([])
  const [bookings, setBookings] = useState<Booking[]>([])
  const [loading, setLoading] = useState(true)

  useEffect(() => {
    let mounted = true
    Promise.all([listServices(), listBookings()])
      .then(([s, b]) => {
        if (!mounted) return
        setServices(s)
        setBookings(b)
      })
      .catch(() => { /* silent — palette still usable */ })
      .finally(() => { if (mounted) setLoading(false) })
    return () => { mounted = false }
  }, [])

  return { services, bookings, loading }
}
QUALITY_REFACTOR_FILE

write_file 'src/components/service-form/FieldError.tsx' <<'QUALITY_REFACTOR_FILE'
import type { ReactNode } from 'react'

export default function FieldError({ children }: { children: ReactNode }) {
  return <span style={{ color: 'var(--danger)', fontSize: 12, marginTop: 4 }}>{children}</span>
}
QUALITY_REFACTOR_FILE

write_file 'src/components/service-form/ServiceBasicsFields.tsx' <<'QUALITY_REFACTOR_FILE'
import type { ChangeEvent } from 'react'
import { Field } from '../UI'
import { useT } from '../../i18n/SettingsContext'
import type { ServiceFormErrors, ServiceFormValues } from './serviceFormTypes'
import FieldError from './FieldError'

interface ServiceBasicsFieldsProps {
  values: ServiceFormValues
  errors: ServiceFormErrors
  setField: (key: keyof ServiceFormValues) => (e: ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => void
  markTouched: (key: keyof ServiceFormValues) => () => void
}

export default function ServiceBasicsFields({ values, errors, setField, markTouched }: ServiceBasicsFieldsProps) {
  const t = useT()

  return (
    <div className="grid grid-2">
      <Field label={t('serviceForm.tag.en')}>
        <input
          className="input"
          value={values.tagEn}
          onChange={setField('tagEn')}
          onBlur={markTouched('tagEn')}
          aria-invalid={!!errors.tagEn}
          placeholder="Strategy, Consultation, ..."
        />
        {errors.tagEn && <FieldError>{errors.tagEn}</FieldError>}
      </Field>

      <Field label={t('serviceForm.tag.ru')}>
        <input
          className="input"
          value={values.tagRu}
          onChange={setField('tagRu')}
          onBlur={markTouched('tagRu')}
          aria-invalid={!!errors.tagRu}
          placeholder="Стратегия, Консультация, ..."
        />
        {errors.tagRu && <FieldError>{errors.tagRu}</FieldError>}
      </Field>

      <Field label={t('serviceForm.name.en')}>
        <input
          className="input"
          value={values.nameEn}
          onChange={setField('nameEn')}
          onBlur={markTouched('nameEn')}
          aria-invalid={!!errors.nameEn}
        />
        {errors.nameEn && <FieldError>{errors.nameEn}</FieldError>}
      </Field>

      <Field label={t('serviceForm.name.ru')}>
        <input
          className="input"
          value={values.nameRu}
          onChange={setField('nameRu')}
          onBlur={markTouched('nameRu')}
          aria-invalid={!!errors.nameRu}
        />
        {errors.nameRu && <FieldError>{errors.nameRu}</FieldError>}
      </Field>

      <Field label={t('serviceForm.duration')}>
        <input
          className="input"
          type="number"
          min={1}
          value={values.duration}
          onChange={setField('duration')}
          onBlur={markTouched('duration')}
          aria-invalid={!!errors.duration}
        />
        {errors.duration && <FieldError>{errors.duration}</FieldError>}
      </Field>

      <Field label={t('serviceForm.price')}>
        <input
          className="input"
          type="number"
          min={0}
          value={values.price}
          onChange={setField('price')}
          onBlur={markTouched('price')}
          aria-invalid={!!errors.price}
        />
        {errors.price && <FieldError>{errors.price}</FieldError>}
      </Field>
    </div>
  )
}
QUALITY_REFACTOR_FILE

write_file 'src/components/service-form/ServiceDetailsFields.tsx' <<'QUALITY_REFACTOR_FILE'
import type { ChangeEvent } from 'react'
import { Field } from '../UI'
import { useT } from '../../i18n/SettingsContext'
import type { ServiceFormErrors, ServiceFormValues } from './serviceFormTypes'
import FieldError from './FieldError'

interface ServiceDetailsFieldsProps {
  values: ServiceFormValues
  errors: ServiceFormErrors
  setField: (key: keyof ServiceFormValues) => (e: ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => void
  markTouched: (key: keyof ServiceFormValues) => () => void
}

export default function ServiceDetailsFields({ values, errors, setField, markTouched }: ServiceDetailsFieldsProps) {
  const t = useT()

  return (
    <>
      <Field label={t('serviceForm.tone')}>
        <select className="select" value={values.tone} onChange={setField('tone')}>
          <option value="muted">{t('serviceForm.tone.muted')}</option>
          <option value="accent">{t('serviceForm.tone.accent')}</option>
        </select>
      </Field>

      <Field label={t('serviceForm.desc.en')}>
        <textarea
          className="textarea"
          value={values.descEn}
          onChange={setField('descEn')}
          onBlur={markTouched('descEn')}
          aria-invalid={!!errors.descEn}
        />
        {errors.descEn && <FieldError>{errors.descEn}</FieldError>}
      </Field>

      <Field label={t('serviceForm.desc.ru')}>
        <textarea
          className="textarea"
          value={values.descRu}
          onChange={setField('descRu')}
          onBlur={markTouched('descRu')}
          aria-invalid={!!errors.descRu}
        />
        {errors.descRu && <FieldError>{errors.descRu}</FieldError>}
      </Field>
    </>
  )
}
QUALITY_REFACTOR_FILE

write_file 'src/components/service-form/serviceFormTypes.ts' <<'QUALITY_REFACTOR_FILE'
import type { PillTone } from '../../types'

export interface ServiceFormValues {
  tagEn: string
  tagRu: string
  tone: PillTone
  duration: number | string
  price: number | string
  nameEn: string
  nameRu: string
  descEn: string
  descRu: string
}

export type ServiceFormErrors = Partial<Record<keyof ServiceFormValues, string>>
export type ServiceFormTouched = Partial<Record<keyof ServiceFormValues, boolean>>
QUALITY_REFACTOR_FILE

write_file 'src/components/service-form/serviceFormUtils.ts' <<'QUALITY_REFACTOR_FILE'
import type { Service, ServicePayload } from '../../types'
import type { TKey } from '../../i18n/translations'
import type { ServiceFormErrors, ServiceFormValues } from './serviceFormTypes'

export const EMPTY_SERVICE_FORM: ServiceFormValues = {
  tagEn: '',
  tagRu: '',
  tone: 'muted',
  duration: 60,
  price: 50,
  nameEn: '',
  nameRu: '',
  descEn: '',
  descRu: '',
}

type TFn = (key: TKey, params?: Record<string, string | number>) => string

export function toServiceFormValues(service: Service | null): ServiceFormValues {
  if (!service) return EMPTY_SERVICE_FORM
  return {
    tagEn: service.tag?.en || '',
    tagRu: service.tag?.ru || '',
    tone: service.tone || 'muted',
    duration: service.duration ?? 60,
    price: service.price ?? 50,
    nameEn: service.name?.en || '',
    nameRu: service.name?.ru || '',
    descEn: service.description?.en || '',
    descRu: service.description?.ru || '',
  }
}

export function toServicePayload(values: ServiceFormValues): ServicePayload {
  return {
    tag: { en: String(values.tagEn).trim(), ru: String(values.tagRu).trim() },
    tone: values.tone,
    duration: Number(values.duration),
    price: Number(values.price),
    name: { en: String(values.nameEn).trim(), ru: String(values.nameRu).trim() },
    description: { en: String(values.descEn).trim(), ru: String(values.descRu).trim() },
  }
}

export function validateServiceForm(values: ServiceFormValues, t: TFn): ServiceFormErrors {
  const errors: ServiceFormErrors = {}
  if (!String(values.tagEn).trim()) errors.tagEn = t('validation.required')
  if (!String(values.tagRu).trim()) errors.tagRu = t('validation.required')
  if (!String(values.nameEn).trim()) errors.nameEn = t('validation.required')
  if (!String(values.nameRu).trim()) errors.nameRu = t('validation.required')
  if (!String(values.descEn).trim()) errors.descEn = t('validation.required')
  if (!String(values.descRu).trim()) errors.descRu = t('validation.required')

  const duration = Number(values.duration)
  if (!Number.isFinite(duration) || duration <= 0) errors.duration = t('validation.positiveNumber')

  const price = Number(values.price)
  if (!Number.isFinite(price) || price < 0) errors.price = t('validation.nonNegativeNumber')

  return errors
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/Booking.tsx' <<'QUALITY_REFACTOR_FILE'
import { useEffect, useMemo, useState } from 'react'
import { useNavigate, useSearchParams } from 'react-router-dom'
import { createBooking, listBookings } from '../data/bookingsApi'
import { listServices } from '../data/servicesApi'
import { getAvailability } from '../data/availabilityApi'
import { loc } from '../data/mock'
import { useT, useSettings } from '../i18n/SettingsContext'
import { useDelayedFlag } from '../components/Skeleton'
import type { AvailabilitySlot, Booking, DayHours, Service } from '../types'
import type { CustomerForm, Step } from './booking/bookingTypes'
import {
  addMinutesHHMM, getBookingEventDates, initialsFrom,
  isDateInPast, toISODate, toMinutes,
} from './booking/bookingUtils'
import DetailsForm from './booking/DetailsForm'
import ServiceStep from './booking/ServiceStep'
import DateTimeStep from './booking/DateTimeStep'
import ConfirmStep from './booking/ConfirmStep'
import BookingHeader from './booking/BookingHeader'

export default function Booking() {
  const navigate = useNavigate()
  const [searchParams, setSearchParams] = useSearchParams()
  const preselectServiceId = searchParams.get('service')
  const t = useT()
  const { lang } = useSettings()

  const [step, setStep] = useState<Step>(1)
  const [selectedServiceId, setSelectedServiceId] = useState<string | null>(null)

  // Step 1 filter state
  const [step1Tag, setStep1Tag] = useState<string>('all')
  const [step1Query, setStep1Query] = useState('')

  const [date, setDate] = useState<Date>(() => new Date())
  const [time, setTime] = useState('11:00')

  // These are the EXTERNAL client's details (the person being booked into the
  // user's calendar), so we start empty — never prefill from the logged-in user.
  const [customer, setCustomer] = useState<CustomerForm>({ name: '', email: '', phone: '', notes: '' })
  const [termsAccepted, setTermsAccepted] = useState(false)
  const [termsError, setTermsError] = useState(false)

  const [services, setServices] = useState<Service[]>([])
  // Existing bookings — used to render orange dots on the calendar for days
  // where the user already has appointments.
  const [bookings, setBookings] = useState<Booking[]>([])
  const [loading, setLoading] = useState(true)
  const [saving, setSaving] = useState(false)
  const [error, setError] = useState('')
  const step1Loading = useDelayedFlag(loading)

  // Availability for the currently selected (service, date). Fetched on step 2.
  const [availSlots, setAvailSlots] = useState<AvailabilitySlot[]>([])
  const [availWindow, setAvailWindow] = useState<DayHours | null>(null)
  const [availLoading, setAvailLoading] = useState(false)
  const [availError, setAvailError] = useState<string | null>(null)

  const selectedService = useMemo<Service | null>(
    // Compare via String() to handle json-server's mixed number/string ids.
    () => services.find(s => String(s.id) === String(selectedServiceId)) || null,
    [services, selectedServiceId]
  )

  const dateLabel = date.toLocaleDateString(lang === 'ru' ? 'ru-RU' : 'en-US', { weekday: 'short', month: 'short', day: 'numeric' })
  const dateISO = useMemo(() => toISODate(date), [date])

  useEffect(() => {
    let mounted = true
    setLoading(true)
    Promise.all([listServices(), listBookings()])
      .then(([svcRows, bkRows]) => {
        if (!mounted) return
        setServices(Array.isArray(svcRows) ? svcRows : [])
        setBookings(Array.isArray(bkRows) ? bkRows : [])
      })
      .catch(() => {
        if (!mounted) return
        setServices([])
        setBookings([])
      })
      .finally(() => { if (mounted) setLoading(false) })
    return () => { mounted = false }
  }, [])

  // Days where the user has at least one non-cancelled booking — rendered as
  // orange dots under the day number in the calendar.
  const eventsOn = useMemo<Date[]>(() => getBookingEventDates(bookings), [bookings])

  // Preselect a service from ?service=<id> query param.
  // Compare via String() — json-server may return id as number but URL param is always a string.
  useEffect(() => {
    if (!preselectServiceId || services.length === 0) return
    const match = services.find(s => String(s.id) === String(preselectServiceId))
    if (!match) return
    setSelectedServiceId(String(match.id))
    setStep(2)
    setSearchParams({}, { replace: true })
  }, [preselectServiceId, services, setSearchParams])

  // Fetch availability from the server whenever the (service, date) pair changes.
  // The server knows about ALL provider's bookings (not just ones this user can see),
  // so this is the only way to avoid double-booking across customers.
  useEffect(() => {
    if (!selectedService) return
    let mounted = true
    setAvailLoading(true)
    setAvailError(null)
    getAvailability(selectedService.providerId, dateISO, selectedService.duration)
      .then((res) => {
        if (!mounted) return
        setAvailSlots(res.slots)
        setAvailWindow(res.workingHours)
      })
      .catch((err: unknown) => {
        if (!mounted) return
        setAvailSlots([])
        setAvailWindow(null)
        // 404 means the provider record vanished (orphan service). Tell the user
        // explicitly instead of pretending it's just a day off.
        const status = (err as { status?: number })?.status
        setAvailError(status === 404 ? t('booking.providerMissing') : t('booking.errorCreate'))
      })
      .finally(() => { if (mounted) setAvailLoading(false) })
    return () => { mounted = false }
  }, [selectedService, dateISO, t])

  // Split slots into morning (< 13:00) and afternoon for visual grouping.
  const morningSlots    = useMemo(() => availSlots.filter(s => toMinutes(s.time) <  13 * 60), [availSlots])
  const afternoonSlots  = useMemo(() => availSlots.filter(s => toMinutes(s.time) >= 13 * 60), [availSlots])
  const disabledTimeSet = useMemo(() => new Set(availSlots.filter(s => !s.available).map(s => s.time)), [availSlots])
  const allFreeTimes    = useMemo(() => availSlots.filter(s => s.available).map(s => s.time), [availSlots])
  const dayOff          = !availLoading && availWindow === null
  const hasFreeSlots    = allFreeTimes.length > 0

  const isPastDate = useMemo(() => isDateInPast(date), [date])

  // Auto-pick the first available slot when (date, slots) change, if current pick is invalid.
  useEffect(() => {
    if (availLoading || availSlots.length === 0) return
    const currentValid = availSlots.some(s => s.time === time && s.available)
    if (currentValid) return
    if (allFreeTimes.length > 0) setTime(allFreeTimes[0])
  }, [availSlots, allFreeTimes, time, availLoading])

  // ============== ACTIONS ==============

  const onPickService = (id: string) => {
    setSelectedServiceId(id)
    setStep(2)
  }

  const goToDetails = () => {
    setError('')
    if (isPastDate) {
      setError(t('booking.errorPastDate'))
      return
    }
    if (disabledTimeSet.has(time) || !hasFreeSlots) {
      setError(t('booking.errorSlotTaken'))
      return
    }
    setStep(3)
  }

  const onSubmitDetails = (data: CustomerForm) => {
    setCustomer(data)
    setStep(4)
  }

  const onConfirm = async () => {
    if (!termsAccepted) { setTermsError(true); return }
    setTermsError(false)
    setError('')
    if (!selectedService) { setStep(1); return }
    if (isPastDate) { setError(t('booking.errorPastDate')); setStep(2); return }
    if (disabledTimeSet.has(time)) { setError(t('booking.errorSlotTaken')); setStep(2); return }

    try {
      setSaving(true)
      const created = await createBooking({
        dateISO,
        time,
        endTime: addMinutesHHMM(time, selectedService.duration),
        durationMin: selectedService.duration,
        serviceId: selectedService.id,
        service: loc(selectedService.name, lang),
        total: selectedService.price,
        withName: customer.name,
        initials: initialsFrom(customer.name),
        status: 'confirmed',
        customerEmail: customer.email,
        customerPhone: customer.phone || null,
        notes: customer.notes || null,
      })
      sessionStorage.setItem('lastBooking', JSON.stringify(created))
      navigate('/confirmation')
    } catch {
      setError(t('booking.errorCreate'))
    } finally {
      setSaving(false)
    }
  }


  // ============== STEP 1 ==============
  if (step === 1) {
    return (
      <>
        <BookingHeader step={step} />
        <ServiceStep
          services={services}
          loading={loading}
          showSkeleton={step1Loading}
          selectedServiceId={selectedServiceId}
          selectedTag={step1Tag}
          query={step1Query}
          onTagChange={setStep1Tag}
          onQueryChange={setStep1Query}
          onPickService={onPickService}
        />
      </>
    )
  }

  // ============== STEP 2 ==============
  if (step === 2) {
    return (
      <>
        <BookingHeader step={step} />
        <DateTimeStep
          date={date}
          dateLabel={dateLabel}
          eventsOn={eventsOn}
          error={error}
          availabilityError={availError}
          dayOff={dayOff}
          morningSlots={morningSlots}
          afternoonSlots={afternoonSlots}
          selectedTime={time}
          selectedService={selectedService}
          availabilityLoading={availLoading}
          bookedSlotsCount={availSlots.length - allFreeTimes.length}
          continueDisabled={availLoading || !!availError || !selectedService || isPastDate || dayOff || !hasFreeSlots || disabledTimeSet.has(time)}
          onDateChange={setDate}
          onTimeChange={setTime}
          onBack={() => setStep(1)}
          onContinue={goToDetails}
        />
      </>
    )
  }

  // ============== STEP 3 ==============
  if (step === 3) {
    return (
      <>
        <BookingHeader step={step} />
        <DetailsForm
          defaultValues={customer}
          onSubmit={onSubmitDetails}
          onBack={() => setStep(2)}
        />
      </>
    )
  }

  // ============== STEP 4 ==============
  return (
    <>
      <BookingHeader step={step} />
      <ConfirmStep
        selectedService={selectedService}
        customer={customer}
        dateLabel={dateLabel}
        time={time}
        termsAccepted={termsAccepted}
        termsError={termsError}
        error={error}
        saving={saving}
        onTermsChange={(accepted) => {
          setTermsAccepted(accepted)
          if (accepted) setTermsError(false)
        }}
        onBack={() => setStep(3)}
        onConfirm={onConfirm}
      />
    </>
  )

}
QUALITY_REFACTOR_FILE

write_file 'src/pages/BookingDetail.tsx' <<'QUALITY_REFACTOR_FILE'
import { useEffect, useState } from 'react'
import { useNavigate, useParams } from 'react-router-dom'
import { getBooking, patchBooking, deleteBooking } from '../data/bookingsApi'
import { useT } from '../i18n/SettingsContext'
import { useConfirm } from '../components/Confirm'
import { useToast } from '../components/Toast'
import { useDelayedFlag } from '../components/Skeleton'
import type { Booking } from '../types'
import BookingDetailActions from './booking-detail/BookingDetailActions'
import BookingCustomerCard from './booking-detail/BookingCustomerCard'
import BookingDetailHeader from './booking-detail/BookingDetailHeader'
import { BookingDetailNotFound, BookingDetailSkeleton } from './booking-detail/BookingDetailState'
import BookingNotesCard from './booking-detail/BookingNotesCard'
import BookingSummaryCard from './booking-detail/BookingSummaryCard'

export default function BookingDetail() {
  const t = useT()
  const confirm = useConfirm()
  const toast = useToast()
  const { id } = useParams<{ id: string }>()
  const navigate = useNavigate()

  const [booking, setBooking] = useState<Booking | null>(null)
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [busy, setBusy] = useState(false)

  // Back to wherever the user came from; fallback to /bookings if no history.
  const goBack = () => {
    if (window.history.length > 1) navigate(-1)
    else navigate('/bookings')
  }

  useEffect(() => {
    if (!id) return
    let mounted = true
    setLoading(true)
    getBooking(id)
      .then((data) => { if (mounted) { setBooking(data); setError(null) } })
      .catch(() => { if (mounted) setError(t('bookings.detail.notFound')) })
      .finally(() => { if (mounted) setLoading(false) })
    return () => { mounted = false }
  }, [id, t])

  const onCancel = async () => {
    if (!booking) return
    const ok = await confirm({
      title: t('bookings.action.cancel'),
      message: t('bookings.cancelConfirm', {
        service: booking.service,
        date: booking.dateISO,
        time: booking.time,
      }),
      confirmText: t('bookings.action.cancel'),
      danger: true,
    })
    if (!ok) return

    try {
      setBusy(true)
      await patchBooking(booking.id, { status: 'cancelled' })
      setBooking({ ...booking, status: 'cancelled' })
      toast.success(t('bookings.action.cancel'))
    } catch (e) {
      toast.error(e instanceof Error ? e.message : 'Failed to cancel')
    } finally {
      setBusy(false)
    }
  }

  const onDelete = async () => {
    if (!booking) return
    const ok = await confirm({
      title: t('bookings.action.delete'),
      message: t('bookings.deleteConfirm', {
        service: booking.service,
        date: booking.dateISO,
        time: booking.time,
      }),
      confirmText: t('bookings.action.delete'),
      danger: true,
    })
    if (!ok) return

    try {
      setBusy(true)
      await deleteBooking(booking.id)
      toast.success(t('bookings.action.delete'))
      navigate('/bookings')
    } catch (e) {
      toast.error(e instanceof Error ? e.message : 'Failed to delete')
      setBusy(false)
    }
  }

  const showSkeleton = useDelayedFlag(loading)
  if (loading) return showSkeleton ? <BookingDetailSkeleton /> : null

  if (error || !booking) {
    return <BookingDetailNotFound title={error || t('bookings.detail.notFound')} onBack={goBack} />
  }

  return (
    <div style={{ maxWidth: 720 }}>
      <BookingDetailHeader booking={booking} onBack={goBack} />
      <BookingSummaryCard booking={booking} />
      <BookingCustomerCard booking={booking} />
      <BookingNotesCard booking={booking} />
      <BookingDetailActions booking={booking} busy={busy} onCancel={onCancel} onDelete={onDelete} />
    </div>
  )
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/Bookings.tsx' <<'QUALITY_REFACTOR_FILE'
import { useCallback, useEffect, useMemo, useState } from 'react'
import RescheduleModal from '../components/RescheduleModal'
import { listBookings, deleteBooking, patchBooking } from '../data/bookingsApi'
import { useT, useSettings } from '../i18n/SettingsContext'
import { useConfirm } from '../components/Confirm'
import { useToast } from '../components/Toast'
import { useDelayedFlag } from '../components/Skeleton'
import type { Booking } from '../types'
import type { TabItem } from '../components/UI'
import BookingsHeader from './bookings/BookingsHeader'
import BookingsFilters from './bookings/BookingsFilters'
import BookingsTable from './bookings/BookingsTable'
import {
  BookingsError,
  BookingsSkeleton,
  EmptyBookingsState,
  FirstRunEmptyState,
} from './bookings/BookingsState'
import type { StatusTab } from './bookings/bookingsTypes'
import {
  addMinutesHHMM,
  annotateBookings,
  filterBookings,
  formatDateShort,
  groupBookingsByStatus,
  sortBookings,
} from './bookings/bookingsUtils'

export default function Bookings() {
  const t = useT()
  const { lang } = useSettings()
  const confirm = useConfirm()
  const toast = useToast()

  const [status, setStatus] = useState<StatusTab>('upcoming')
  const [query, setQuery] = useState('')
  const [editing, setEditing] = useState<Booking | null>(null)
  const [bookings, setBookings] = useState<Booking[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [busyId, setBusyId] = useState<string | null>(null)

  const load = useCallback(() => {
    setLoading(true)
    listBookings()
      .then((data) => {
        setBookings(sortBookings(data))
        setError(null)
      })
      .catch(() => setError(t('bookings.errorServer')))
      .finally(() => setLoading(false))
  }, [t])

  useEffect(() => { load() }, [load])

  // Wrap into uniform shape so downstream code (which used to read `.b`/`.role`)
  // still works after the role-split was removed in the single-tenant refactor.
  const annotated = useMemo(() => annotateBookings(bookings), [bookings])
  const groups = useMemo(() => groupBookingsByStatus(annotated), [annotated])
  const visible = useMemo(() => filterBookings(groups, status, query), [groups, status, query])

  const handleReschedule = async (dateISO: string, time: string) => {
    if (!editing) return
    const endTime = addMinutesHHMM(time, editing.durationMin || 60)
    const updated = await patchBooking(editing.id, { dateISO, time, endTime })
    setBookings(prev => prev.map(x => x.id === editing.id ? { ...x, ...updated } : x))
    toast.success(t('common.save'))
  }

  const handleCancel = async (b: Booking) => {
    const ok = await confirm({
      title: t('bookings.action.cancel'),
      message: t('bookings.cancelConfirm', {
        service: b.service,
        date: formatDateShort(b.dateISO, lang),
        time: b.time,
      }),
      confirmText: t('bookings.action.cancel'),
      danger: true,
    })
    if (!ok) return

    try {
      setBusyId(b.id)
      await patchBooking(b.id, { status: 'cancelled' })
      setBookings(prev => prev.map(x => x.id === b.id ? { ...x, status: 'cancelled' } : x))
      toast.success(t('bookings.action.cancel'))
    } catch (e) {
      toast.error(e instanceof Error ? e.message : 'Failed to cancel booking')
    } finally {
      setBusyId(null)
    }
  }

  const handleDelete = async (b: Booking) => {
    const ok = await confirm({
      title: t('bookings.action.delete'),
      message: t('bookings.deleteConfirm', {
        service: b.service,
        date: formatDateShort(b.dateISO, lang),
        time: b.time,
      }),
      confirmText: t('bookings.action.delete'),
      danger: true,
    })
    if (!ok) return

    try {
      setBusyId(b.id)
      await deleteBooking(b.id)
      setBookings(prev => prev.filter(x => x.id !== b.id))
      toast.success(t('bookings.action.delete'))
    } catch (e) {
      toast.error(e instanceof Error ? e.message : 'Failed to delete booking')
    } finally {
      setBusyId(null)
    }
  }

  // Hide tab counts while loading — they'd flicker from 0 → N once data arrives.
  const count = (n: number) => loading ? undefined : n
  const tabs: TabItem<StatusTab>[] = [
    { value: 'upcoming', label: t('bookings.tab.upcoming'), count: count(groups.upcoming.length) },
    { value: 'past', label: t('bookings.tab.past'), count: count(groups.past.length) },
    { value: 'cancelled', label: t('bookings.tab.cancelled'), count: count(groups.cancelled.length) },
  ]

  const showSkeleton = useDelayedFlag(loading)
  const isFirstRun = !loading && !error && annotated.length === 0

  return (
    <>
      <BookingsHeader loading={loading} onRefresh={load} />

      {!isFirstRun && (
        <BookingsFilters
          tabs={tabs}
          status={status}
          query={query}
          onStatusChange={setStatus}
          onQueryChange={setQuery}
        />
      )}

      {error && <BookingsError error={error} />}
      {!error && loading && showSkeleton && <BookingsSkeleton />}
      {isFirstRun && <FirstRunEmptyState />}
      {!error && !loading && !isFirstRun && visible.length === 0 && (
        <EmptyBookingsState status={status} query={query} />
      )}
      {visible.length > 0 && (
        <BookingsTable
          items={visible}
          status={status}
          busyId={busyId}
          onEdit={setEditing}
          onCancel={handleCancel}
          onDelete={handleDelete}
        />
      )}

      <RescheduleModal
        booking={editing}
        onClose={() => setEditing(null)}
        onSubmit={handleReschedule}
      />
    </>
  )
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/Dashboard.tsx' <<'QUALITY_REFACTOR_FILE'
import { useEffect, useMemo, useState } from 'react'
import { listBookings } from '../data/bookingsApi'
import { useT } from '../i18n/SettingsContext'
import { useAuth } from '../i18n/AuthContext'
import { addDays, isSameDay, startOfWeek } from '../utils/date'
import type { Booking } from '../types'
import DashboardHeader from './dashboard/DashboardHeader'
import DashboardStatsGrid from './dashboard/DashboardStatsGrid'
import WeekCalendar from './dashboard/WeekCalendar'
import UpcomingBookings from './dashboard/UpcomingBookings'
import {
  calculateDashboardStats,
  getHourBounds,
  getHours,
  getUpcomingBookings,
  groupWeekEvents,
} from './dashboard/dashboardUtils'
import { useDelayedFlag } from '../components/Skeleton'

export default function Dashboard() {
  const t = useT()
  const { user } = useAuth()
  const userId = user?.id
  // Greeting prefers displayName (e.g. "Anna"), falls back to full name's first word.
  const greetingName = user?.displayName || user?.name?.split(' ')[0] || ''

  const [rawBookings, setRawBookings] = useState<Booking[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)

  // Current week shown in the week-calendar (mutable via prev/today/next).
  const [weekAnchor, setWeekAnchor] = useState<Date>(() => new Date())

  useEffect(() => {
    let mounted = true
    listBookings()
      .then((data) => { if (mounted) { setRawBookings(data); setError(null) } })
      .catch(() => { if (mounted) setError(t('dashboard.errorServer')) })
      .finally(() => { if (mounted) setLoading(false) })
    return () => { mounted = false }
  }, [t])

  // Dashboard is the "specialist panel": only show bookings where the current
  // user is the PROVIDER. Customer-side bookings live in /bookings under
  // the "Mine" scope.
  const bookings = useMemo(
    () => userId == null ? [] : rawBookings.filter(b => Number(b.providerId) === userId),
    [rawBookings, userId],
  )

  const stats = useMemo(() => calculateDashboardStats(bookings), [bookings])

  const weekStart = useMemo(() => startOfWeek(weekAnchor), [weekAnchor])
  const days = useMemo(() => Array.from({ length: 7 }, (_, i) => addDays(weekStart, i)), [weekStart])
  const weekEventsByDay = useMemo(
    () => groupWeekEvents(bookings, weekAnchor, days),
    [bookings, weekAnchor, days],
  )
  const hourBounds = useMemo(() => getHourBounds(weekEventsByDay), [weekEventsByDay])
  const hours = useMemo(() => getHours(hourBounds), [hourBounds])
  const upcoming = useMemo(() => getUpcomingBookings(bookings), [bookings])

  const today = new Date()
  const isCurrentWeek = isSameDay(startOfWeek(today), weekStart)
  const showSkeleton = useDelayedFlag(loading)

  return (
    <>
      <DashboardHeader greetingName={greetingName} todayCount={stats.todayCount} />

      {error && (
        <div className="card mb-6" style={{ borderColor: 'rgba(248,113,113,0.32)', color: 'var(--danger)' }}>
          {error}
        </div>
      )}

      <DashboardStatsGrid stats={stats} loading={loading} showSkeleton={showSkeleton} />

      <WeekCalendar
        days={days}
        hours={hours}
        today={today}
        isCurrentWeek={isCurrentWeek}
        hourBounds={hourBounds}
        weekEventsByDay={weekEventsByDay}
        onPrevWeek={() => setWeekAnchor(addDays(weekAnchor, -7))}
        onToday={() => setWeekAnchor(new Date())}
        onNextWeek={() => setWeekAnchor(addDays(weekAnchor, 7))}
      />

      <UpcomingBookings
        bookings={upcoming}
        loading={loading}
        error={error}
        showSkeleton={showSkeleton}
      />
    </>
  )
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/Login.tsx' <<'QUALITY_REFACTOR_FILE'
import { Link, useNavigate, useLocation } from 'react-router-dom'
import { useState, type FormEvent } from 'react'
import { Button, Field } from '../components/UI'
import { useT } from '../i18n/SettingsContext'
import { useAuth } from '../i18n/AuthContext'
import { AuthError } from '../data/authApi'
import { useToast } from '../components/Toast'
import AuthShell from '../components/auth/AuthShell'

interface LocationState {
  from?: { pathname?: string }
}

export default function Login() {
  const navigate = useNavigate()
  const location = useLocation()
  const t = useT()
  const { login } = useAuth()
  const toast = useToast()
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [submitting, setSubmitting] = useState(false)

  // Where to send the user after successful login.
  // Fallback to /dashboard, avoid bouncing back to /login.
  const state = location.state as LocationState | null
  const fromPath = state?.from?.pathname
  const redirectTo = fromPath && fromPath !== '/login' ? fromPath : '/dashboard'

  const submit = async (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    if (submitting) return
    setSubmitting(true)
    try {
      await login({ email: email.trim(), password })
      navigate(redirectTo, { replace: true })
    } catch (err) {
      if (err instanceof AuthError) {
        toast.error(err.status === 400 ? t('login.error.invalid') : err.message)
      } else {
        toast.error(t('login.error.server'))
      }
    } finally {
      setSubmitting(false)
    }
  }

  return (
    <AuthShell
      title={t('login.welcome')}
      subtitle={t('login.subtitle')}
      footer={<>{t('login.noAccount')} <Link to="/register" className="btn-text">{t('login.signUp')}</Link></>}
    >
      <form onSubmit={submit}>
        <Field label={t('login.email')}>
          <input className="input" type="email" value={email} onChange={(e) => setEmail(e.target.value)} />
        </Field>
        <Field label={t('login.password')}>
          <input className="input" type="password" value={password} onChange={(e) => setPassword(e.target.value)} />
        </Field>

        <div className="flex-between mb-6" style={{ fontSize: 13 }}>
          <label className="flex flex-gap-2 text-muted" style={{ alignItems: 'center', cursor: 'pointer' }}>
            <input type="checkbox" defaultChecked /> {t('login.remember')}
          </label>
          <Link to="#" className="btn-text">{t('login.forgot')}</Link>
        </div>

        <Button size="lg" block type="submit" disabled={submitting}>
          {submitting ? t('login.signingIn') : t('login.signIn')}
        </Button>

        <div className="flex flex-gap-3" style={{ alignItems: 'center', margin: 'var(--s-6) 0' }}>
          <div style={{ flex: 1, height: 1, background: 'var(--border)' }} />
          <span className="text-subtle" style={{ fontSize: 12 }}>{t('login.or')}</span>
          <div style={{ flex: 1, height: 1, background: 'var(--border)' }} />
        </div>

        <Button variant="ghost" size="lg" block type="button" className="mb-2">{t('login.google')}</Button>
        <Button variant="ghost" size="lg" block type="button">{t('login.apple')}</Button>
      </form>
    </AuthShell>
  )
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/Profile.tsx' <<'QUALITY_REFACTOR_FILE'
import { useState, type ChangeEvent, type FormEvent } from 'react'
import { useNavigate } from 'react-router-dom'
import { Button } from '../components/UI'
import { useT, useSettings } from '../i18n/SettingsContext'
import { useAuth } from '../i18n/AuthContext'
import { useToast } from '../components/Toast'
import { useConfirm } from '../components/Confirm'
import type { ProfileFormValues } from './profile/profileTypes'
import ProfileFieldsCard from './profile/ProfileFieldsCard'
import AppearanceCard from './profile/AppearanceCard'
import WorkingHoursCard from './profile/WorkingHoursCard'
import { getInitialProfileForm } from './profile/profileUtils'

export default function Profile() {
  const t = useT()
  const toast = useToast()
  const confirm = useConfirm()
  const navigate = useNavigate()
  const { user, logout, updateProfile } = useAuth()
  const { lang, setLang, theme, setTheme } = useSettings()

  const [saving, setSaving] = useState(false)
  const [form, setForm] = useState<ProfileFormValues>(() => getInitialProfileForm(user))

  const updateField = (key: keyof ProfileFormValues) =>
    (e: ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => {
      setForm(prev => ({ ...prev, [key]: e.target.value }))
    }

  const handleLogout = async () => {
    const ok = await confirm({
      title: t('auth.logout'),
      confirmText: t('auth.logout'),
      danger: true,
    })
    if (!ok) return

    logout()
    toast.success(t('auth.loggedOut'))
    navigate('/login', { replace: true })
  }

  const save = async (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    if (saving) return

    setSaving(true)
    try {
      await updateProfile({
        name: form.fullName.trim(),
        displayName: form.displayName.trim() || undefined,
        email: form.email.trim(),
        phone: form.phone.trim() || undefined,
        timezone: form.timezone || undefined,
        bio: form.bio.trim() || undefined,
        workingHours: form.workingHours,
      })
      toast.success(t('profile.saved'))
    } catch {
      toast.error(t('profile.saveError'))
    } finally {
      setSaving(false)
    }
  }

  return (
    <>
      <h1 className="mb-2">{t('profile.title')}</h1>
      <p className="subtitle mb-8">{t('profile.subtitle')}</p>

      <div style={{ maxWidth: 880 }}>
        <form onSubmit={save}>
          <ProfileFieldsCard
            form={form}
            lang={lang}
            onFieldChange={updateField}
            onLangChange={setLang}
          />

          <AppearanceCard lang={lang} theme={theme} onThemeChange={setTheme} />

          <WorkingHoursCard
            value={form.workingHours}
            onChange={(workingHours) => setForm(prev => ({ ...prev, workingHours }))}
          />

          <div className="flex-between" style={{ alignItems: 'center' }}>
            <Button
              variant="ghost"
              type="button"
              onClick={handleLogout}
              style={{ color: 'var(--danger)' }}
            >
              {t('auth.logout')}
            </Button>
            <div className="flex flex-gap-3" style={{ alignItems: 'center' }}>
              <Button variant="ghost" type="button" disabled={saving}>{t('common.cancel')}</Button>
              <Button type="submit" disabled={saving}>
                {saving ? t('common.loading') : t('common.save')}
              </Button>
            </div>
          </div>
        </form>
      </div>
    </>
  )
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/Register.tsx' <<'QUALITY_REFACTOR_FILE'
import { Link, useNavigate } from 'react-router-dom'
import { useState, type FormEvent } from 'react'
import { Button, Field } from '../components/UI'
import { useT } from '../i18n/SettingsContext'
import { useAuth } from '../i18n/AuthContext'
import { AuthError } from '../data/authApi'
import { useToast } from '../components/Toast'
import AuthShell from '../components/auth/AuthShell'
import FieldError from '../components/service-form/FieldError'

const EMAIL_RE = /^[^@\s]+@[^@\s]+\.[^@\s]+$/

type Errors = Partial<Record<'name' | 'email' | 'password' | 'passwordConfirm', string>>

export default function Register() {
  const navigate = useNavigate()
  const t = useT()
  const { register } = useAuth()
  const toast = useToast()

  const [name, setName] = useState('')
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [passwordConfirm, setPasswordConfirm] = useState('')
  const [errors, setErrors] = useState<Errors>({})
  const [submitting, setSubmitting] = useState(false)

  const validate = (): Errors => {
    const e: Errors = {}
    if (!name.trim()) e.name = t('validation.required')
    if (!email.trim()) e.email = t('validation.required')
    else if (!EMAIL_RE.test(email.trim())) e.email = t('validation.email')
    if (!password) e.password = t('validation.required')
    else if (password.length < 6) e.password = t('register.error.passwordShort')
    if (password !== passwordConfirm) e.passwordConfirm = t('register.error.passwordMismatch')
    return e
  }

  const submit = async (ev: FormEvent<HTMLFormElement>) => {
    ev.preventDefault()
    if (submitting) return
    const errs = validate()
    setErrors(errs)
    if (Object.keys(errs).length > 0) return

    setSubmitting(true)
    try {
      await register({ name: name.trim(), email: email.trim(), password })
      navigate('/dashboard', { replace: true })
    } catch (err) {
      if (err instanceof AuthError) {
        // json-server-auth returns 400 with "Email already exists"
        if (err.status === 400 && /already exists/i.test(err.message)) {
          toast.error(t('register.error.emailExists'))
        } else {
          toast.error(err.message)
        }
      } else {
        toast.error(t('login.error.server'))
      }
    } finally {
      setSubmitting(false)
    }
  }

  return (
    <AuthShell
      title={t('register.title')}
      subtitle={t('register.subtitle')}
      footer={<>{t('register.haveAccount')} <Link to="/login" className="btn-text">{t('register.signIn')}</Link></>}
    >
      <form onSubmit={submit} noValidate>
        <Field label={t('register.name')}>
          <input
            className="input"
            autoComplete="name"
            value={name}
            onChange={(e) => setName(e.target.value)}
            aria-invalid={!!errors.name}
          />
          {errors.name && <FieldError>{errors.name}</FieldError>}
        </Field>

        <Field label={t('login.email')}>
          <input
            className="input"
            type="email"
            autoComplete="email"
            value={email}
            onChange={(e) => setEmail(e.target.value)}
            aria-invalid={!!errors.email}
          />
          {errors.email && <FieldError>{errors.email}</FieldError>}
        </Field>

        <Field label={t('register.password')}>
          <input
            className="input"
            type="password"
            autoComplete="new-password"
            value={password}
            onChange={(e) => setPassword(e.target.value)}
            aria-invalid={!!errors.password}
          />
          {errors.password && <FieldError>{errors.password}</FieldError>}
        </Field>

        <Field label={t('register.passwordConfirm')}>
          <input
            className="input"
            type="password"
            autoComplete="new-password"
            value={passwordConfirm}
            onChange={(e) => setPasswordConfirm(e.target.value)}
            aria-invalid={!!errors.passwordConfirm}
          />
          {errors.passwordConfirm && <FieldError>{errors.passwordConfirm}</FieldError>}
        </Field>

        <Button size="lg" block type="submit" disabled={submitting}>
          {submitting ? t('register.submitting') : t('register.submit')}
        </Button>
      </form>
    </AuthShell>
  )
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/Services.tsx' <<'QUALITY_REFACTOR_FILE'
import { useCallback, useEffect, useMemo, useState } from 'react'
import Modal from '../components/Modal'
import ServiceForm from '../components/ServiceForm'
import { loc } from '../data/mock'
import { listServices, createService, patchService, deleteService } from '../data/servicesApi'
import { useT, useSettings } from '../i18n/SettingsContext'
import { useConfirm } from '../components/Confirm'
import { useToast } from '../components/Toast'
import { useDelayedFlag } from '../components/Skeleton'
import type { Service, ServicePayload } from '../types'
import ServicesHeader from './services/ServicesHeader'
import ServicesSearch from './services/ServicesSearch'
import ServicesGrid from './services/ServicesGrid'
import { EmptyServicesState, ServicesError, ServicesSkeleton } from './services/ServicesState'
import type { EditingState } from './services/servicesTypes'
import { isEditingService } from './services/servicesTypes'
import { buildServiceFilters, filterServices } from './services/servicesUtils'

export default function Services() {
  const t = useT()
  const { lang } = useSettings()
  const confirm = useConfirm()
  const toast = useToast()

  const [services, setServices] = useState<Service[]>([])
  const [loading, setLoading] = useState(true)
  const [error, setError] = useState<string | null>(null)
  const [tab, setTab] = useState<string>('all')
  const [query, setQuery] = useState('')
  const [editing, setEditing] = useState<EditingState>(null)
  const [saving, setSaving] = useState(false)
  const [busyId, setBusyId] = useState<string | null>(null)

  const load = useCallback((): Promise<void> => {
    setLoading(true)
    return listServices()
      .then((data) => { setServices(data); setError(null) })
      .catch(() => setError(t('services.errorServer')))
      .finally(() => setLoading(false))
  }, [t])

  useEffect(() => { void load() }, [load])

  const filters = useMemo(
    () => buildServiceFilters(services, query, lang, t('services.tab.all')),
    [services, query, lang, t],
  )
  const visible = useMemo(() => filterServices(services, tab, query, lang), [services, tab, query, lang])

  const openCreate = () => setEditing({ __new: true })
  const modalTitle = isEditingService(editing) ? t('services.modal.edit') : t('services.modal.create')
  const isEmptySearch = !loading && !error && services.length > 0 && visible.length === 0
  const showSkeleton = useDelayedFlag(loading)

  const onDelete = async (service: Service) => {
    const ok = await confirm({
      title: t('services.action.delete'),
      message: t('services.deleteConfirm', { name: loc(service.name, lang) }),
      confirmText: t('services.action.delete'),
      danger: true,
    })
    if (!ok) return

    try {
      setBusyId(service.id)
      await deleteService(service.id)
      setServices(prev => prev.filter(s => s.id !== service.id))
      toast.success(t('services.action.delete'))
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to delete')
    } finally {
      setBusyId(null)
    }
  }

  const handleSubmit = async (payload: ServicePayload) => {
    try {
      setSaving(true)
      if (isEditingService(editing)) await patchService(editing.id, payload)
      else await createService(payload)
      await load()
      setEditing(null)
      toast.success(t('common.save'))
    } catch (err) {
      toast.error(err instanceof Error ? err.message : 'Failed to save')
    } finally {
      setSaving(false)
    }
  }

  return (
    <>
      <ServicesHeader onCreate={openCreate} />
      <ServicesSearch query={query} onQueryChange={setQuery} />

      {error && <ServicesError error={error} />}
      {!error && loading && showSkeleton && <ServicesSkeleton />}
      {!error && !loading && services.length === 0 && <EmptyServicesState onCreate={openCreate} />}
      {!error && !loading && services.length > 0 && (
        <ServicesGrid
          services={visible}
          filters={filters}
          activeFilter={tab}
          isEmptySearch={isEmptySearch}
          busyId={busyId}
          onFilterChange={setTab}
          onEdit={setEditing}
          onDelete={onDelete}
        />
      )}

      <Modal open={editing !== null} onClose={() => !saving && setEditing(null)} title={modalTitle}>
        {editing !== null && (
          <ServiceForm
            service={isEditingService(editing) ? editing : null}
            onSubmit={handleSubmit}
            onCancel={() => setEditing(null)}
            saving={saving}
          />
        )}
      </Modal>
    </>
  )
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/booking-detail/BookingCustomerCard.tsx' <<'QUALITY_REFACTOR_FILE'
import { Avatar, Card, LabelMono } from '../../components/UI'
import { useT } from '../../i18n/SettingsContext'
import type { Booking } from '../../types'

export default function BookingCustomerCard({ booking }: { booking: Booking }) {
  const t = useT()

  return (
    <Card className="mb-6">
      <LabelMono>{t('bookings.detail.section.customer')}</LabelMono>
      <div className="flex flex-gap-3 mt-4" style={{ alignItems: 'center' }}>
        <Avatar initials={booking.initials || '?'} size={40} />
        <div>
          <div style={{ fontWeight: 600 }}>{booking.withName || '—'}</div>
          <div className="text-muted" style={{ fontSize: 13 }}>{booking.customerEmail}</div>
          {booking.customerPhone && (
            <div className="text-muted mono" style={{ fontSize: 13 }}>{booking.customerPhone}</div>
          )}
        </div>
      </div>
    </Card>
  )
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/booking-detail/BookingDetailActions.tsx' <<'QUALITY_REFACTOR_FILE'
import { Button, Divider } from '../../components/UI'
import { useT } from '../../i18n/SettingsContext'
import { downloadIcs } from '../../utils/ics'
import type { Booking } from '../../types'
import { getBookingRef } from './bookingDetailUtils'

interface BookingDetailActionsProps {
  booking: Booking
  busy: boolean
  onCancel: () => void
  onDelete: () => void
}

export default function BookingDetailActions({ booking, busy, onCancel, onDelete }: BookingDetailActionsProps) {
  const t = useT()
  const isCancelled = booking.status === 'cancelled'
  const ref = getBookingRef(booking.id)

  return (
    <>
      <Divider />

      <div className="flex flex-gap-3 mt-4">
        <Button onClick={() => downloadIcs(booking, `slottr-${ref}.ics`)} disabled={busy}>
          {t('conf.btn.addToCal')}
        </Button>
        {!isCancelled && (
          <Button variant="ghost" onClick={onCancel} disabled={busy} style={{ color: 'var(--warning)' }}>
            {busy ? t('bookings.cancelling') : t('bookings.action.cancel')}
          </Button>
        )}
        <Button variant="ghost" onClick={onDelete} disabled={busy} style={{ color: 'var(--danger)' }}>
          {busy ? t('bookings.deleting') : t('bookings.action.delete')}
        </Button>
      </div>
    </>
  )
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/booking-detail/BookingDetailHeader.tsx' <<'QUALITY_REFACTOR_FILE'
import { Pill } from '../../components/UI'
import { useT } from '../../i18n/SettingsContext'
import type { Booking } from '../../types'
import { getBookingRef, getStatusTone } from './bookingDetailUtils'

interface BookingDetailHeaderProps {
  booking: Booking
  onBack: () => void
}

export default function BookingDetailHeader({ booking, onBack }: BookingDetailHeaderProps) {
  const t = useT()

  return (
    <>
      <button onClick={onBack} className="btn-text" style={{ fontSize: 13, cursor: 'pointer' }}>
        {t('bookings.detail.backToList')}
      </button>

      <div className="flex-between mt-4 mb-2" style={{ alignItems: 'flex-start' }}>
        <h1>{booking.service}</h1>
        <Pill tone={getStatusTone(booking.status)}>{t(`status.${booking.status}`)}</Pill>
      </div>
      <p className="subtitle mb-8 mono">#{getBookingRef(booking.id)}</p>
    </>
  )
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/booking-detail/BookingDetailState.tsx' <<'QUALITY_REFACTOR_FILE'
import EmptyState from '../../components/EmptyState'
import { Skeleton } from '../../components/Skeleton'
import { useT } from '../../i18n/SettingsContext'

export function BookingDetailSkeleton() {
  return (
    <div style={{ maxWidth: 720 }}>
      <Skeleton width={80} height={14} style={{ marginBottom: 16 }} />
      <Skeleton width="50%" height={32} style={{ marginBottom: 8 }} />
      <Skeleton width={120} height={14} style={{ marginBottom: 32 }} />
      <Skeleton width="100%" height={120} radius={14} style={{ marginBottom: 24 }} />
      <Skeleton width="100%" height={80} radius={14} style={{ marginBottom: 24 }} />
      <Skeleton width="100%" height={80} radius={14} />
    </div>
  )
}

export function BookingDetailNotFound({ title, onBack }: { title: string; onBack: () => void }) {
  const t = useT()

  return (
    <>
      <button onClick={onBack} className="btn-text" style={{ fontSize: 13, cursor: 'pointer' }}>
        {t('bookings.detail.backToList')}
      </button>
      <EmptyState illustration="calendar" title={title} />
    </>
  )
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/booking-detail/BookingNotesCard.tsx' <<'QUALITY_REFACTOR_FILE'
import { Card, LabelMono } from '../../components/UI'
import { useT } from '../../i18n/SettingsContext'
import type { Booking } from '../../types'

export default function BookingNotesCard({ booking }: { booking: Booking }) {
  const t = useT()

  return (
    <Card className="mb-6">
      <LabelMono>{t('bookings.detail.section.notes')}</LabelMono>
      <div
        className={booking.notes ? '' : 'text-subtle'}
        style={{ marginTop: 8, whiteSpace: 'pre-wrap', fontSize: 14 }}
      >
        {booking.notes || t('bookings.detail.noNotes')}
      </div>
    </Card>
  )
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/booking-detail/BookingSummaryCard.tsx' <<'QUALITY_REFACTOR_FILE'
import { Card, LabelMono } from '../../components/UI'
import { useT, useSettings } from '../../i18n/SettingsContext'
import type { Booking } from '../../types'
import { formatBookingDate, getBookingTimeRange } from './bookingDetailUtils'

export default function BookingSummaryCard({ booking }: { booking: Booking }) {
  const t = useT()
  const { lang } = useSettings()

  return (
    <Card className="mb-6">
      <div className="grid grid-2">
        <div>
          <LabelMono>{t('conf.field.date')}</LabelMono>
          <div style={{ fontWeight: 600, marginTop: 8 }}>{formatBookingDate(booking.dateISO, lang)}</div>
        </div>
        <div>
          <LabelMono>{t('conf.field.time')}</LabelMono>
          <div className="mono" style={{ marginTop: 8 }}>
            {getBookingTimeRange(booking)} ({booking.durationMin || 60} {t('services.minutes')})
          </div>
        </div>
        <div>
          <LabelMono>{t('conf.field.location')}</LabelMono>
          <div style={{ marginTop: 8 }}>{t('conf.location')}</div>
        </div>
        <div>
          <LabelMono>{t('conf.field.total')}</LabelMono>
          <div className="text-accent mono" style={{ marginTop: 8, fontWeight: 600, fontSize: 16 }}>
            ${Number(booking.total || 0).toFixed(2)}
          </div>
        </div>
      </div>
    </Card>
  )
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/booking-detail/bookingDetailUtils.ts' <<'QUALITY_REFACTOR_FILE'
import type { Booking, Lang } from '../../types'

export function formatBookingDate(iso: string | undefined, lang: Lang): string {
  if (!iso) return ''
  const [y, m, d] = iso.split('-').map(Number)
  const date = new Date(y, m - 1, d)
  return date.toLocaleDateString(lang === 'ru' ? 'ru-RU' : 'en-US', {
    weekday: 'short', month: 'long', day: 'numeric', year: 'numeric',
  })
}

export function getBookingRef(id: Booking['id']): string {
  return `SLT-${String(id).padStart(4, '0')}`
}

export function getBookingTimeRange(booking: Booking): string {
  return booking.endTime ? `${booking.time} – ${booking.endTime}` : booking.time
}

export function getStatusTone(status: Booking['status']): 'success' | 'danger' | 'accent' {
  if (status === 'cancelled') return 'danger'
  if (status === 'confirmed') return 'success'
  return 'accent'
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/booking/BookingHeader.tsx' <<'QUALITY_REFACTOR_FILE'
import { Link } from 'react-router-dom'
import { useT } from '../../i18n/SettingsContext'
import type { Step } from './bookingTypes'

interface BookingHeaderProps {
  step: Step
}

export default function BookingHeader({ step }: BookingHeaderProps) {
  const t = useT()

  return (
    <>
      <Link to="/dashboard" className="btn-text">{t('booking.backToDashboard')}</Link>
      <h1 className="mt-4 mb-2">{t('booking.title')}</h1>
      <p className="subtitle mb-8">{t('booking.subtitle')}</p>

      <div className="stepper">
        <div className={`step ${step === 1 ? 'active' : 'done'}`}><span className="num">1</span> {t('booking.step.service')}</div>
        <span className="sep">·</span>
        <div className={`step ${step === 2 ? 'active' : step > 2 ? 'done' : ''}`}><span className="num">2</span> {t('booking.step.dateTime')}</div>
        <span className="sep">·</span>
        <div className={`step ${step === 3 ? 'active' : step > 3 ? 'done' : ''}`}><span className="num">3</span> {t('booking.step.details')}</div>
        <span className="sep">·</span>
        <div className={`step ${step === 4 ? 'active' : ''}`}><span className="num">4</span> {t('booking.step.confirm')}</div>
      </div>
    </>
  )
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/booking/ConfirmStep.tsx' <<'QUALITY_REFACTOR_FILE'
import type { ReactNode } from 'react'
import { Button, Card, Divider, LabelMono } from '../../components/UI'
import { loc } from '../../data/mock'
import { useT, useSettings } from '../../i18n/SettingsContext'
import type { Service } from '../../types'
import type { CustomerForm } from './bookingTypes'
import { addMinutesHHMM } from './bookingUtils'

interface ConfirmStepProps {
  selectedService: Service | null
  customer: CustomerForm
  dateLabel: string
  time: string
  termsAccepted: boolean
  termsError: boolean
  error: string
  saving: boolean
  onTermsChange: (accepted: boolean) => void
  onBack: () => void
  onConfirm: () => void
}

export default function ConfirmStep({
  selectedService,
  customer,
  dateLabel,
  time,
  termsAccepted,
  termsError,
  error,
  saving,
  onTermsChange,
  onBack,
  onConfirm,
}: ConfirmStepProps) {
  const t = useT()
  const { lang } = useSettings()

  return (
    <>
      <h3 className="mb-2">{t('booking.confirm.title')}</h3>
      <p className="text-muted mb-6">{t('booking.confirm.sub')}</p>

      <Card className="mb-6" style={{ maxWidth: 640 }}>
        <SummaryRow label={t('booking.confirm.section.service')}>
          <div style={{ fontWeight: 600 }}>{selectedService ? loc(selectedService.name, lang) : '—'}</div>
          <div className="text-muted mt-2" style={{ fontSize: 13 }}>
            {selectedService?.duration} {t('services.minutes')} · ${selectedService?.price}
          </div>
        </SummaryRow>

        <Divider />

        <SummaryRow label={t('booking.confirm.section.when')}>
          <div style={{ fontWeight: 600 }}>{dateLabel}</div>
          <div className="mono text-muted mt-2" style={{ fontSize: 13 }}>
            {time}–{selectedService ? addMinutesHHMM(time, selectedService.duration) : time}
          </div>
        </SummaryRow>

        <Divider />

        <SummaryRow label={t('booking.confirm.section.customer')}>
          <div style={{ fontWeight: 600 }}>{customer.name}</div>
          <div className="text-muted mt-2" style={{ fontSize: 13 }}>{customer.email}</div>
          {customer.phone && <div className="text-muted mono" style={{ fontSize: 13 }}>{customer.phone}</div>}
        </SummaryRow>

        {customer.notes && (
          <>
            <Divider />
            <SummaryRow label={t('booking.confirm.section.notes')}>
              <div style={{ fontSize: 13, whiteSpace: 'pre-wrap' }}>{customer.notes}</div>
            </SummaryRow>
          </>
        )}
      </Card>

      <div style={{ maxWidth: 640 }}>
        <label className="flex flex-gap-3 mb-2" style={{ alignItems: 'flex-start', cursor: 'pointer', fontSize: 14 }}>
          <input
            type="checkbox"
            checked={termsAccepted}
            onChange={(e) => onTermsChange(e.target.checked)}
            style={{ marginTop: 3 }}
          />
          <span>{t('booking.confirm.terms')}</span>
        </label>
        {termsError && (
          <div className="text-muted mb-4" style={{ color: 'var(--danger)', fontSize: 12 }}>
            {t('validation.terms')}
          </div>
        )}

        {error && <div className="card mb-4"><div>⚠ {error}</div></div>}

        <div className="flex flex-gap-3 mt-4">
          <Button variant="ghost" onClick={onBack} disabled={saving}>{t('common.back')}</Button>
          <Button onClick={onConfirm} disabled={saving}>
            {saving ? t('booking.saving') : t('booking.confirm.btn')}
          </Button>
        </div>
      </div>
    </>
  )
}

function SummaryRow({ label, children }: { label: ReactNode; children: ReactNode }) {
  return (
    <div className="flex" style={{ gap: 'var(--s-6)', padding: 'var(--s-3) 0' }}>
      <div style={{ width: 120, flex: 'none' }}>
        <LabelMono>{label}</LabelMono>
      </div>
      <div style={{ flex: 1, minWidth: 0 }}>{children}</div>
    </div>
  )
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/booking/DateTimeStep.tsx' <<'QUALITY_REFACTOR_FILE'
import { Button, LabelMono } from '../../components/UI'
import Calendar from '../../components/Calendar'
import { loc } from '../../data/mock'
import { useT, useSettings } from '../../i18n/SettingsContext'
import type { AvailabilitySlot, Service } from '../../types'
import { addMinutesHHMM } from './bookingUtils'

interface DateTimeStepProps {
  date: Date
  dateLabel: string
  eventsOn: Date[]
  error: string
  availabilityError: string | null
  dayOff: boolean
  morningSlots: AvailabilitySlot[]
  afternoonSlots: AvailabilitySlot[]
  selectedTime: string
  selectedService: Service | null
  availabilityLoading: boolean
  bookedSlotsCount: number
  continueDisabled: boolean
  onDateChange: (date: Date) => void
  onTimeChange: (time: string) => void
  onBack: () => void
  onContinue: () => void
}

export default function DateTimeStep({
  date,
  dateLabel,
  eventsOn,
  error,
  availabilityError,
  dayOff,
  morningSlots,
  afternoonSlots,
  selectedTime,
  selectedService,
  availabilityLoading,
  bookedSlotsCount,
  continueDisabled,
  onDateChange,
  onTimeChange,
  onBack,
  onContinue,
}: DateTimeStepProps) {
  const t = useT()
  const { lang } = useSettings()

  const renderSlot = (slot: AvailabilitySlot) => (
    <button
      key={slot.time}
      className={`slot-btn ${selectedTime === slot.time ? 'selected' : ''}`}
      disabled={availabilityLoading || !slot.available}
      onClick={() => onTimeChange(slot.time)}
    >
      {slot.time}
    </button>
  )

  return (
    <div className="grid" style={{ gridTemplateColumns: '1.1fr 1fr', gap: 'var(--s-6)' }}>
      <div>
        <h3 className="mb-4">{t('booking.pickDate')}</h3>
        <Calendar value={date} onChange={onDateChange} eventsOn={eventsOn} minDate={new Date()} />
      </div>

      <div>
        <div className="flex-between mb-4">
          <h3>{t('booking.availableTimes')}</h3>
          <LabelMono>{dateLabel}</LabelMono>
        </div>

        {error && <div className="card mb-4"><div>⚠ {error}</div></div>}

        {availabilityError ? (
          <div className="card mb-4" style={{ borderColor: 'rgba(248,113,113,0.32)' }}>
            <div style={{ fontWeight: 600, color: 'var(--danger)' }}>⚠ {availabilityError}</div>
          </div>
        ) : dayOff ? (
          <div className="card mb-4">
            <div style={{ fontWeight: 600 }}>{t('booking.dayOff')}</div>
            <div className="text-muted mt-2" style={{ fontSize: 13 }}>{t('booking.dayOff.desc')}</div>
          </div>
        ) : (
          <>
            <div className="mb-4">
              <LabelMono>{t('booking.morning')}</LabelMono>
              <div className="slots mt-2">{morningSlots.map(renderSlot)}</div>
            </div>

            <div className="mb-6">
              <LabelMono>{t('booking.afternoon')}</LabelMono>
              <div className="slots mt-2">{afternoonSlots.map(renderSlot)}</div>
            </div>
          </>
        )}

        <div className="card mb-4">
          <LabelMono>{t('booking.yourSelection')}</LabelMono>
          <div className="flex-between mt-2">
            <div>
              <div>{selectedService ? loc(selectedService.name, lang) : '—'}</div>
              <div className="text-muted mt-2">
                {dateLabel} · {selectedTime}–{selectedService ? addMinutesHHMM(selectedTime, selectedService.duration) : selectedTime} ({selectedService?.duration || 60} {t('services.minutes')})
              </div>
            </div>
            <div className="text-accent mono">${selectedService?.price ?? 0}</div>
          </div>
        </div>

        <div className="flex flex-gap-3">
          <Button variant="ghost" block onClick={onBack}>{t('common.back')}</Button>
          <Button block onClick={onContinue} disabled={continueDisabled}>
            {t('common.continue')}
          </Button>
        </div>

        <div className="text-muted mt-2">
          {availabilityLoading
            ? t('booking.loadingBookings')
            : dayOff
              ? ''
              : t('booking.bookedSlots', { n: bookedSlotsCount })}
        </div>
      </div>
    </div>
  )
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/booking/DetailsForm.tsx' <<'QUALITY_REFACTOR_FILE'
import { useState, type ChangeEvent, type FormEvent, type ReactNode } from 'react'
import { Button, Field } from '../../components/UI'
import { useT } from '../../i18n/SettingsContext'
import type { CustomerForm, DetailsErrors } from './bookingTypes'
import { validateDetails } from './bookingValidation'

interface DetailsFormProps {
  defaultValues: CustomerForm
  onSubmit: (data: CustomerForm) => void
  onBack: () => void
}

export default function DetailsForm({ defaultValues, onSubmit, onBack }: DetailsFormProps) {
  const t = useT()
  const [values, setValues] = useState<CustomerForm>(defaultValues)
  const [errors, setErrors] = useState<DetailsErrors>({})
  const [touched, setTouched] = useState<Partial<Record<keyof CustomerForm, boolean>>>({})

  const setField = (k: keyof CustomerForm) =>
    (e: ChangeEvent<HTMLInputElement | HTMLTextAreaElement>) => {
      const v = e.target.value
      setValues(prev => ({ ...prev, [k]: v }))
      if (touched[k] || errors[k]) {
        setErrors(validateDetails({ ...values, [k]: v }, t))
      }
    }

  const markTouched = (k: keyof CustomerForm) => () => {
    setTouched(prev => ({ ...prev, [k]: true }))
    setErrors(validateDetails(values, t))
  }

  const submit = (e: FormEvent<HTMLFormElement>) => {
    e.preventDefault()
    const errs = validateDetails(values, t)
    setErrors(errs)
    setTouched({ name: true, email: true, phone: true })
    if (Object.keys(errs).length === 0) {
      onSubmit({
        name: values.name.trim(),
        email: values.email.trim(),
        phone: values.phone.trim(),
        notes: values.notes.trim(),
      })
    }
  }

  return (
    <form onSubmit={submit} noValidate style={{ maxWidth: 560 }}>
      <h3 className="mb-6">{t('booking.yourDetails')}</h3>

      <Field label={t('booking.field.name')}>
        <input
          className="input"
          autoComplete="name"
          value={values.name}
          onChange={setField('name')}
          onBlur={markTouched('name')}
          aria-invalid={!!errors.name}
        />
        {errors.name && <FieldError>{errors.name}</FieldError>}
      </Field>

      <Field label={t('booking.field.email')}>
        <input
          className="input"
          type="email"
          autoComplete="email"
          value={values.email}
          onChange={setField('email')}
          onBlur={markTouched('email')}
          aria-invalid={!!errors.email}
        />
        {errors.email && <FieldError>{errors.email}</FieldError>}
      </Field>

      <Field label={t('booking.field.phone')}>
        <input
          className="input"
          type="tel"
          autoComplete="tel"
          value={values.phone}
          onChange={setField('phone')}
          onBlur={markTouched('phone')}
          aria-invalid={!!errors.phone}
        />
        {errors.phone && <FieldError>{errors.phone}</FieldError>}
      </Field>

      <Field label={t('booking.field.notes')}>
        <textarea
          className="textarea"
          placeholder={t('booking.field.notes.ph')}
          value={values.notes}
          onChange={setField('notes')}
        />
      </Field>

      <div className="flex flex-gap-3 mt-4">
        <Button variant="ghost" type="button" onClick={onBack}>{t('common.back')}</Button>
        <Button type="submit">{t('common.continue')}</Button>
      </div>
    </form>
  )
}

function FieldError({ children }: { children: ReactNode }) {
  return <span style={{ color: 'var(--danger)', fontSize: 12, marginTop: 4 }}>{children}</span>
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/booking/ServiceStep.tsx' <<'QUALITY_REFACTOR_FILE'
import { Link } from 'react-router-dom'
import { Button, Card, Pill } from '../../components/UI'
import EmptyState from '../../components/EmptyState'
import SearchBox from '../../components/SearchBox'
import { SkeletonCardGrid } from '../../components/Skeleton'
import { loc } from '../../data/mock'
import { useT, useSettings } from '../../i18n/SettingsContext'
import type { Service } from '../../types'
import { matchesServiceQuery } from './bookingUtils'

interface ServiceStepProps {
  services: Service[]
  loading: boolean
  showSkeleton: boolean
  selectedServiceId: string | null
  selectedTag: string
  query: string
  onTagChange: (tag: string) => void
  onQueryChange: (query: string) => void
  onPickService: (id: string) => void
}

export default function ServiceStep({
  services,
  loading,
  showSkeleton,
  selectedServiceId,
  selectedTag,
  query,
  onTagChange,
  onQueryChange,
  onPickService,
}: ServiceStepProps) {
  const t = useT()
  const { lang } = useSettings()

  const matchedAll = services.filter(s => matchesServiceQuery(s, query, lang))
  const seen = new Map<string, Service['tag']>()
  for (const s of services) {
    const key = s.tag?.en
    if (key && !seen.has(key)) seen.set(key, s.tag)
  }

  const filters = [
    { value: 'all', label: t('services.tab.all'), count: matchedAll.length },
    ...[...seen.entries()].map(([key, tag]) => ({
      value: key,
      label: loc(tag, lang),
      count: matchedAll.filter(s => s.tag?.en === key).length,
    })),
  ]

  let visible = services
  if (selectedTag !== 'all') visible = visible.filter(s => s.tag?.en === selectedTag)
  if (query) visible = visible.filter(s => matchesServiceQuery(s, query, lang))

  const isEmptySearch = !loading && services.length > 0 && visible.length === 0

  return (
    <>
      <h3 className="mb-2">{t('booking.chooseService')}</h3>
      <p className="text-muted mb-6">{t('booking.chooseServiceSub')}</p>

      {loading && showSkeleton && <SkeletonCardGrid />}

      {!loading && services.length === 0 && (
        <EmptyState
          illustration="services"
          title={t('booking.catalogEmpty')}
          description={t('booking.catalogEmpty.desc')}
          action={<Button as="link" to="/services">{t('services.add')}</Button>}
        />
      )}

      {!loading && services.length > 0 && (
        <>
          <SearchBox
            value={query}
            onChange={onQueryChange}
            placeholder={t('services.search.placeholder')}
          />

          <div className="services-layout">
            <aside className="services-filters">
              <div className="filter-label">{t('services.filters')}</div>
              {filters.map(f => (
                <button
                  key={f.value}
                  className={`filter-item ${selectedTag === f.value ? 'active' : ''}`}
                  onClick={() => onTagChange(f.value)}
                >
                  <span>{f.label}</span>
                  <span className="count">{f.count}</span>
                </button>
              ))}
            </aside>

            <div>
              {isEmptySearch ? (
                <EmptyState illustration="search" title={t('services.search.empty')} />
              ) : (
                <div className="services-grid">
                  {visible.map((s) => {
                    const isSelected = String(s.id) === String(selectedServiceId)
                    return (
                      <Card
                        key={s.id}
                        interactive
                        onClick={() => onPickService(s.id)}
                        style={isSelected ? { borderColor: 'var(--accent)' } : undefined}
                      >
                        <div className="flex-between mb-4">
                          <Pill tone={s.tone}>{loc(s.tag, lang)}</Pill>
                          <span className="mono text-muted" style={{ fontSize: 12 }}>{s.duration} {t('services.minutes')}</span>
                        </div>
                        <h3 className="mb-2">{loc(s.name, lang)}</h3>
                        <p className="text-muted line-clamp-3" style={{ fontSize: 13 }}>{loc(s.description, lang)}</p>
                        <div className="flex-between mt-auto" style={{ paddingTop: 'var(--s-6)' }}>
                          <span className="text-accent mono" style={{ fontSize: 16, fontWeight: 600 }}>${s.price}</span>
                          <Link
                            to={`/services/${s.id}`}
                            onClick={(e) => e.stopPropagation()}
                            className="btn-text"
                            style={{ fontSize: 13 }}
                          >
                            {t('services.details')}
                          </Link>
                        </div>
                      </Card>
                    )
                  })}
                </div>
              )}
            </div>
          </div>
        </>
      )}
    </>
  )
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/booking/bookingTypes.ts' <<'QUALITY_REFACTOR_FILE'
export type Step = 1 | 2 | 3 | 4

export interface CustomerForm {
  name: string
  email: string
  phone: string
  notes: string
}

export type DetailsErrors = Partial<Record<keyof CustomerForm, string>>
QUALITY_REFACTOR_FILE

write_file 'src/pages/booking/bookingUtils.ts' <<'QUALITY_REFACTOR_FILE'
import { loc } from '../../data/mock'
import type { Booking, Lang, Service } from '../../types'

export function toISODate(d: Date): string {
  const yyyy = d.getFullYear()
  const mm = String(d.getMonth() + 1).padStart(2, '0')
  const dd = String(d.getDate()).padStart(2, '0')
  return `${yyyy}-${mm}-${dd}`
}

export function addMinutesHHMM(time: string, minutesToAdd: number): string {
  const [hStr, mStr] = time.split(':')
  const total = Number(hStr) * 60 + Number(mStr) + minutesToAdd
  const h = String(Math.floor(total / 60) % 24).padStart(2, '0')
  const m = String(total % 60).padStart(2, '0')
  return `${h}:${m}`
}

// "10:00" -> 600 (minutes since 00:00)
export function toMinutes(time: string): number {
  const [h, m] = time.split(':').map(Number)
  return h * 60 + m
}

// "Anna Smith" -> "AS"
export function initialsFrom(name: string): string {
  if (!name) return '?'
  return name.trim().split(/\s+/).slice(0, 2).map(w => w[0]?.toUpperCase() || '').join('') || '?'
}

export function matchesServiceQuery(s: Service, q: string, lang: Lang): boolean {
  if (!q) return true
  const haystack = [
    loc(s.name, lang), loc(s.description, lang), loc(s.tag, lang),
    s.name?.en, s.name?.ru, s.description?.en, s.description?.ru, s.tag?.en, s.tag?.ru,
  ].filter(Boolean).join(' ').toLowerCase()
  return haystack.includes(q.toLowerCase())
}

export function getBookingEventDates(bookings: Booking[]): Date[] {
  const dates: Date[] = []
  for (const b of bookings) {
    if (!b.dateISO || b.status === 'cancelled') continue
    const [y, m, d] = b.dateISO.split('-').map(Number)
    if (!y || !m || !d) continue
    dates.push(new Date(y, m - 1, d))
  }
  return dates
}

export function isDateInPast(date: Date): boolean {
  const today = new Date()
  const todayMid = new Date(today.getFullYear(), today.getMonth(), today.getDate())
  const selectedMid = new Date(date.getFullYear(), date.getMonth(), date.getDate())
  return selectedMid < todayMid
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/booking/bookingValidation.ts' <<'QUALITY_REFACTOR_FILE'
import type { TKey } from '../../i18n/translations'
import type { CustomerForm, DetailsErrors } from './bookingTypes'

const EMAIL_RE = /^[^@\s]+@[^@\s]+\.[^@\s]+$/
const PHONE_RE = /^[+\d\s()\-]{6,}$/

type TFn = (key: TKey, params?: Record<string, string | number>) => string

export function validateDetails(values: CustomerForm, t: TFn): DetailsErrors {
  const errors: DetailsErrors = {}
  if (!values.name.trim()) errors.name = t('validation.required')
  if (!values.email.trim()) errors.email = t('validation.required')
  else if (!EMAIL_RE.test(values.email.trim())) errors.email = t('validation.email')
  if (values.phone.trim() && !PHONE_RE.test(values.phone.trim())) errors.phone = t('validation.phone')
  return errors
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/bookings/BookingsFilters.tsx' <<'QUALITY_REFACTOR_FILE'
import { Tabs, type TabItem } from '../../components/UI'
import SearchBox from '../../components/SearchBox'
import { useT } from '../../i18n/SettingsContext'
import type { StatusTab } from './bookingsTypes'

interface BookingsFiltersProps {
  tabs: TabItem<StatusTab>[]
  status: StatusTab
  query: string
  onStatusChange: (status: StatusTab) => void
  onQueryChange: (query: string) => void
}

export default function BookingsFilters({
  tabs,
  status,
  query,
  onStatusChange,
  onQueryChange,
}: BookingsFiltersProps) {
  const t = useT()

  return (
    <>
      <Tabs items={tabs} value={status} onChange={onStatusChange} />
      <SearchBox
        className="mb-4"
        value={query}
        onChange={onQueryChange}
        placeholder={t('bookings.search.placeholder')}
      />
    </>
  )
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/bookings/BookingsHeader.tsx' <<'QUALITY_REFACTOR_FILE'
import { Button } from '../../components/UI'
import { useT } from '../../i18n/SettingsContext'

interface BookingsHeaderProps {
  loading: boolean
  onRefresh: () => void
}

export default function BookingsHeader({ loading, onRefresh }: BookingsHeaderProps) {
  const t = useT()

  return (
    <div className="flex-between mb-6">
      <div>
        <h1>{t('bookings.title')}</h1>
        <p className="subtitle mt-2">{t('bookings.subtitle')}</p>
      </div>
      <div className="flex flex-gap-2">
        <Button variant="ghost" size="sm" onClick={onRefresh} disabled={loading}>
          {loading ? t('common.loading') : t('common.refresh')}
        </Button>
        <Button as="link" to="/booking" size="sm">+ {t('nav.newBooking')}</Button>
      </div>
    </div>
  )
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/bookings/BookingsState.tsx' <<'QUALITY_REFACTOR_FILE'
import { Button } from '../../components/UI'
import EmptyState from '../../components/EmptyState'
import { SkeletonTableRow } from '../../components/Skeleton'
import { useT } from '../../i18n/SettingsContext'
import { BookingsTableHead } from './BookingsTable'
import type { StatusTab } from './bookingsTypes'

interface BookingsErrorProps {
  error: string
}

export function BookingsError({ error }: BookingsErrorProps) {
  return (
    <div className="mb-4" style={{
      padding: '12px 16px', border: '1px solid rgba(248,113,113,0.32)',
      background: 'rgba(248,113,113,0.12)', color: 'var(--danger)',
      borderRadius: 'var(--r-md)', fontSize: 13,
    }}>{error}</div>
  )
}

export function BookingsSkeleton() {
  return (
    <table className="table">
      <BookingsTableHead />
      <tbody>
        {Array.from({ length: 5 }, (_, i) => <SkeletonTableRow key={i} cols={7} />)}
      </tbody>
    </table>
  )
}

export function FirstRunEmptyState() {
  const t = useT()

  return (
    <EmptyState
      illustration="calendar"
      title={t('bookings.empty.first')}
      description={t('bookings.empty.first.desc')}
      action={
        <div className="flex flex-gap-2">
          <Button as="link" to="/booking">+ {t('nav.newBooking')}</Button>
          <Button as="link" to="/services" variant="ghost">{t('services.add')}</Button>
        </div>
      }
    />
  )
}

export function EmptyBookingsState({ status, query }: { status: StatusTab; query: string }) {
  const t = useT()

  if (query.trim()) {
    return <EmptyState illustration="search" title={t('bookings.search.empty')} />
  }

  const titleMap: Record<StatusTab, string> = {
    upcoming: t('bookings.empty.upcoming'),
    past: t('bookings.empty.past'),
    cancelled: t('bookings.empty.cancelled'),
  }
  const descMap: Record<StatusTab, string> = {
    upcoming: t('bookings.empty.upcoming.desc'),
    past: t('bookings.empty.past.desc'),
    cancelled: t('bookings.empty.cancelled.desc'),
  }

  return (
    <EmptyState
      illustration="calendar"
      title={titleMap[status]}
      description={descMap[status]}
      action={status === 'upcoming'
        ? <Button as="link" to="/booking">+ {t('nav.newBooking')}</Button>
        : undefined}
    />
  )
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/bookings/BookingsTable.tsx' <<'QUALITY_REFACTOR_FILE'
import { Link } from 'react-router-dom'
import { Avatar, Pill } from '../../components/UI'
import { useT, useSettings } from '../../i18n/SettingsContext'
import type { Booking } from '../../types'
import type { AnnotatedBooking, StatusTab } from './bookingsTypes'
import { formatDateShort } from './bookingsUtils'

interface BookingsTableProps {
  items: AnnotatedBooking[]
  status: StatusTab
  busyId: string | null
  onEdit: (booking: Booking) => void
  onCancel: (booking: Booking) => void
  onDelete: (booking: Booking) => void
}

export default function BookingsTable({
  items,
  status,
  busyId,
  onEdit,
  onCancel,
  onDelete,
}: BookingsTableProps) {
  const t = useT()
  const { lang } = useSettings()

  return (
    <table className="table">
      <BookingsTableHead actions />
      <tbody>
        {items.map(({ b }) => {
          const isBusy = busyId === b.id
          const showCancel = status === 'upcoming'

          return (
            <tr key={b.id}>
              <td className="mono">{formatDateShort(b.dateISO, lang)}</td>
              <td className="mono">{b.time}</td>
              <td>{b.service}</td>
              <td>
                <div className="flex flex-gap-2" style={{ alignItems: 'center' }}>
                  <Avatar initials={b.initials || '?'} size={24} />
                  {b.withName || '—'}
                </div>
              </td>
              <td>
                <Pill tone={
                  b.status === 'confirmed' ? 'success' :
                  b.status === 'cancelled' ? 'danger' : 'accent'
                }>
                  {t(`status.${b.status}`)}
                </Pill>
              </td>
              <td className="mono">${b.total}</td>
              <td style={{ textAlign: 'right' }}>
                <div className="flex flex-gap-2" style={{ justifyContent: 'flex-end' }}>
                  <Link to={`/bookings/${b.id}`} className="btn-text">{t('action.view')}</Link>
                  {showCancel && (
                    <>
                      <button
                        onClick={() => onEdit(b)}
                        disabled={isBusy}
                        className="btn-text"
                        style={{ cursor: 'pointer' }}
                      >
                        {t('bookings.action.edit')}
                      </button>
                      <button
                        onClick={() => onCancel(b)}
                        disabled={isBusy}
                        className="btn-text"
                        style={{ color: 'var(--warning)', cursor: 'pointer' }}
                      >
                        {isBusy ? t('bookings.cancelling') : t('bookings.action.cancel')}
                      </button>
                    </>
                  )}
                  <button
                    onClick={() => onDelete(b)}
                    disabled={isBusy}
                    className="btn-text"
                    style={{ color: 'var(--danger)', cursor: 'pointer' }}
                  >
                    {isBusy ? t('bookings.deleting') : t('bookings.action.delete')}
                  </button>
                </div>
              </td>
            </tr>
          )
        })}
      </tbody>
    </table>
  )
}

export function BookingsTableHead({ actions = false }: { actions?: boolean }) {
  const t = useT()

  return (
    <thead>
      <tr>
        <th>{t('table.date')}</th><th>{t('table.time')}</th>
        <th>{t('table.service')}</th><th>{t('table.with')}</th>
        <th>{t('table.status')}</th><th>{t('table.total')}</th>
        <th style={actions ? { textAlign: 'right' } : undefined}>{actions ? t('table.actions') : undefined}</th>
      </tr>
    </thead>
  )
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/bookings/bookingsTypes.ts' <<'QUALITY_REFACTOR_FILE'
import type { Booking } from '../../types'

export type StatusTab = 'upcoming' | 'past' | 'cancelled'

export interface AnnotatedBooking {
  b: Booking
}

export interface BookingGroups {
  upcoming: AnnotatedBooking[]
  past: AnnotatedBooking[]
  cancelled: AnnotatedBooking[]
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/bookings/bookingsUtils.ts' <<'QUALITY_REFACTOR_FILE'
import type { Booking, Lang } from '../../types'
import type { AnnotatedBooking, BookingGroups, StatusTab } from './bookingsTypes'

export function formatDateShort(iso: string | undefined, lang: Lang): string {
  if (!iso) return '—'
  const [y, m, d] = iso.split('-').map(Number)
  const date = new Date(y, m - 1, d)
  return date.toLocaleDateString(lang === 'ru' ? 'ru-RU' : 'en-US', { month: 'short', day: 'numeric' })
}

export function toISODate(d: Date): string {
  const yyyy = d.getFullYear()
  const mm = String(d.getMonth() + 1).padStart(2, '0')
  const dd = String(d.getDate()).padStart(2, '0')
  return `${yyyy}-${mm}-${dd}`
}

export function sortBookings(bookings: Booking[]): Booking[] {
  return [...bookings].sort((a, b) => {
    const byDate = (a.dateISO || '').localeCompare(b.dateISO || '')
    if (byDate !== 0) return byDate
    return (a.time || '').localeCompare(b.time || '')
  })
}

export function annotateBookings(bookings: Booking[]): AnnotatedBooking[] {
  return bookings.map(b => ({ b }))
}

export function groupBookingsByStatus(annotated: AnnotatedBooking[], todayISO = toISODate(new Date())): BookingGroups {
  const upcoming: AnnotatedBooking[] = []
  const past: AnnotatedBooking[] = []
  const cancelled: AnnotatedBooking[] = []

  for (const x of annotated) {
    if (x.b.status === 'cancelled') cancelled.push(x)
    else if ((x.b.dateISO || '') >= todayISO) upcoming.push(x)
    else past.push(x)
  }

  return { upcoming, past, cancelled }
}

export function filterBookings(
  groups: BookingGroups,
  status: StatusTab,
  query: string,
): AnnotatedBooking[] {
  const list = groups[status] || []
  const q = query.trim().toLowerCase()
  if (!q) return list

  return list.filter(({ b }) =>
    (b.withName || '').toLowerCase().includes(q) ||
    (b.service || '').toLowerCase().includes(q) ||
    (b.customerEmail || '').toLowerCase().includes(q) ||
    (b.dateISO || '').includes(q),
  )
}

export function addMinutesHHMM(time: string, minutesToAdd: number): string {
  const [hStr, mStr] = time.split(':')
  const total = Number(hStr) * 60 + Number(mStr) + minutesToAdd
  return `${String(Math.floor(total / 60) % 24).padStart(2, '0')}:${String(total % 60).padStart(2, '0')}`
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/dashboard/DashboardHeader.tsx' <<'QUALITY_REFACTOR_FILE'
import { useT } from '../../i18n/SettingsContext'

interface DashboardHeaderProps {
  greetingName: string
  todayCount: number
}

export default function DashboardHeader({ greetingName, todayCount }: DashboardHeaderProps) {
  const t = useT()

  return (
    <div className="mb-6">
      <h1>{t('dashboard.greeting', { name: greetingName })}</h1>
      <p className="subtitle mt-2">{t('dashboard.subtitle', { n: todayCount })}</p>
    </div>
  )
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/dashboard/DashboardStatsGrid.tsx' <<'QUALITY_REFACTOR_FILE'
import { Stat } from '../../components/UI'
import { SkeletonStat } from '../../components/Skeleton'
import { useT } from '../../i18n/SettingsContext'
import type { DashboardDelta, DashboardStats } from './dashboardUtils'

interface DashboardStatsGridProps {
  stats: DashboardStats
  loading: boolean
  showSkeleton: boolean
}

export default function DashboardStatsGrid({ stats, loading, showSkeleton }: DashboardStatsGridProps) {
  const t = useT()

  const renderDelta = (d: DashboardDelta | null, key: 'vsYesterday' | 'vsLastWeek' | 'vsLastMonth') => {
    if (!d) return undefined
    return t(`dashboard.stat.delta.${key}`, { n: d.value })
  }

  return (
    <div className="grid grid-4 mb-8">
      {loading && showSkeleton ? (
        <>
          <SkeletonStat /><SkeletonStat /><SkeletonStat /><SkeletonStat />
        </>
      ) : (
        <>
          <Stat
            label={t('dashboard.stat.today')}
            value={loading ? '—' : stats.todayCount}
            delta={renderDelta(stats.todayDelta, 'vsYesterday')}
            down={stats.todayDelta?.down}
          />
          <Stat
            label={t('dashboard.stat.week')}
            value={loading ? '—' : stats.weekCount}
            delta={renderDelta(stats.weekDelta, 'vsLastWeek')}
            down={stats.weekDelta?.down}
          />
          <Stat
            label={t('dashboard.stat.revenue')}
            value={loading ? '—' : `$${stats.monthRevenue.toLocaleString('en-US')}`}
            delta={renderDelta(stats.monthRevenueDelta, 'vsLastMonth')}
            down={stats.monthRevenueDelta?.down}
          />
          <Stat
            label={t('dashboard.stat.cancellations')}
            value={loading ? '—' : stats.monthCancellations}
            delta={renderDelta(stats.monthCancellationsDelta, 'vsLastMonth')}
            // For cancellations, "more" is bad — flip the colour intuitively.
            down={stats.monthCancellationsDelta ? !stats.monthCancellationsDelta.down && stats.monthCancellationsDelta.value !== '0' : undefined}
          />
        </>
      )}
    </div>
  )
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/dashboard/UpcomingBookings.tsx' <<'QUALITY_REFACTOR_FILE'
import { Link } from 'react-router-dom'
import { Button, Pill, Avatar } from '../../components/UI'
import EmptyState from '../../components/EmptyState'
import { SkeletonTableRow } from '../../components/Skeleton'
import { useT } from '../../i18n/SettingsContext'
import type { Booking } from '../../types'

interface UpcomingBookingsProps {
  bookings: Booking[]
  loading: boolean
  error: string | null
  showSkeleton: boolean
}

export default function UpcomingBookings({ bookings, loading, error, showSkeleton }: UpcomingBookingsProps) {
  const t = useT()

  return (
    <>
      <h2 className="mb-4">{t('dashboard.upcomingNext')}</h2>

      {!error && loading && showSkeleton && (
        <table className="table">
          <TableHead />
          <tbody>
            {Array.from({ length: 3 }, (_, i) => <SkeletonTableRow key={i} cols={6} />)}
          </tbody>
        </table>
      )}

      {!error && !loading && bookings.length === 0 && (
        <EmptyState
          illustration="calendar"
          title={t('dashboard.empty')}
          action={<Button as="link" to="/booking">+ {t('nav.newBooking')}</Button>}
        />
      )}

      {!error && !loading && bookings.length > 0 && (
        <table className="table">
          <TableHead />
          <tbody>
            {bookings.map((b) => (
              <tr key={b.id}>
                <td className="mono">{b.dateISO}</td>
                <td className="mono">{b.time}</td>
                <td>{b.service}</td>
                <td>
                  <div className="flex flex-gap-2" style={{ alignItems: 'center' }}>
                    <Avatar initials={b.initials || '?'} size={24} />
                    {b.withName || '—'}
                  </div>
                </td>
                <td><Pill tone={b.status === 'confirmed' ? 'success' : 'accent'}>{t(`status.${b.status}`)}</Pill></td>
                <td><Link to={`/bookings/${b.id}`} className="btn-text">{t('action.view.arrow')}</Link></td>
              </tr>
            ))}
          </tbody>
        </table>
      )}
    </>
  )
}

function TableHead() {
  const t = useT()

  return (
    <thead>
      <tr>
        <th>{t('table.date')}</th>
        <th>{t('table.time')}</th>
        <th>{t('table.service')}</th>
        <th>{t('table.with')}</th>
        <th>{t('table.status')}</th>
        <th />
      </tr>
    </thead>
  )
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/dashboard/WeekCalendar.tsx' <<'QUALITY_REFACTOR_FILE'
import { Link } from 'react-router-dom'
import { Button } from '../../components/UI'
import { useT, useSettings } from '../../i18n/SettingsContext'
import { isSameDay } from '../../utils/date'
import type { Booking, Lang } from '../../types'
import { getEventGeometry, type HourBounds } from './dashboardUtils'

const DOW_LABELS: Record<Lang, string[]> = {
  en: ['MON', 'TUE', 'WED', 'THU', 'FRI', 'SAT', 'SUN'],
  ru: ['ПН', 'ВТ', 'СР', 'ЧТ', 'ПТ', 'СБ', 'ВС'],
}

interface WeekCalendarProps {
  days: Date[]
  hours: string[]
  today: Date
  isCurrentWeek: boolean
  hourBounds: HourBounds
  weekEventsByDay: Record<number, Booking[]>
  onPrevWeek: () => void
  onToday: () => void
  onNextWeek: () => void
}

export default function WeekCalendar({
  days,
  hours,
  today,
  isCurrentWeek,
  hourBounds,
  weekEventsByDay,
  onPrevWeek,
  onToday,
  onNextWeek,
}: WeekCalendarProps) {
  const t = useT()
  const { lang } = useSettings()

  return (
    <>
      <div className="flex-between mb-4">
        <h2>{t('dashboard.thisWeek')}</h2>
        <div className="flex flex-gap-2">
          <Button variant="ghost" size="sm" onClick={onPrevWeek}>{t('dashboard.prev')}</Button>
          <Button variant="ghost" size="sm" onClick={onToday} disabled={isCurrentWeek}>{t('dashboard.today')}</Button>
          <Button variant="ghost" size="sm" onClick={onNextWeek}>{t('dashboard.next')}</Button>
        </div>
      </div>

      <div className="week mb-8">
        <div className="week-head">
          <div className="col" />
          {days.map((d, i) => (
            <div className={`col ${isSameDay(d, today) ? 'today' : ''}`} key={i}>
              {DOW_LABELS[lang][i]}
              <div className="day-num">{d.getDate()}</div>
            </div>
          ))}
        </div>
        <div className="week-body">
          <div className="hour-col">
            {hours.map(h => <div className="hour" key={h}>{h}</div>)}
          </div>
          {days.map((_, i) => (
            <div className="day-col" key={i}>
              {hours.map((_, j) => <div className="slot" key={j} />)}
              {(weekEventsByDay[i] || []).map((b) => {
                const { top, height } = getEventGeometry(b, hourBounds)
                return (
                  <Link
                    to={`/bookings/${b.id}`}
                    key={b.id}
                    className="event"
                    style={{ top, height, textDecoration: 'none' }}
                  >
                    <div className="title">{b.service}</div>
                    <div className="time">
                      {b.time}{b.endTime ? ` – ${b.endTime}` : ''}
                    </div>
                  </Link>
                )
              })}
            </div>
          ))}
        </div>
      </div>
    </>
  )
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/dashboard/dashboardUtils.ts' <<'QUALITY_REFACTOR_FILE'
import {
  addDays, endOfMonth, endOfWeek, isWithinRange,
  startOfMonth, startOfWeek, timeToMinutes, toISODate,
} from '../../utils/date'
import type { Booking } from '../../types'

export const DEFAULT_HOUR_START = 9
export const DEFAULT_HOUR_END = 18
export const HOUR_HEIGHT = 56 // px, matches CSS .slot height

export interface DashboardDelta {
  value: string
  down: boolean
}

export interface DashboardStats {
  todayCount: number
  todayDelta: DashboardDelta | null
  weekCount: number
  weekDelta: DashboardDelta | null
  monthRevenue: number
  monthRevenueDelta: DashboardDelta | null
  monthCancellations: number
  monthCancellationsDelta: DashboardDelta | null
}

export interface HourBounds {
  startHour: number
  endHour: number
}

export function formatDiff(curr: number, prev: number): DashboardDelta | null {
  const diff = curr - prev
  if (diff === 0 && curr === 0) return null
  const sign = diff > 0 ? '+' : diff < 0 ? '−' : ''
  return { value: `${sign}${Math.abs(diff)}`, down: diff < 0 }
}

export function formatMoneyDiff(curr: number, prev: number): DashboardDelta | null {
  const diff = curr - prev
  if (diff === 0 && curr === 0) return null
  const sign = diff > 0 ? '+' : diff < 0 ? '−' : ''
  return { value: `${sign}$${Math.abs(diff).toLocaleString('en-US')}`, down: diff < 0 }
}

export function calculateDashboardStats(bookings: Booking[], now = new Date()): DashboardStats {
  const active = bookings.filter(b => b.status !== 'cancelled')
  const cancelled = bookings.filter(b => b.status === 'cancelled')
  const confirmed = bookings.filter(b => b.status === 'confirmed')

  const todayISO = toISODate(now)
  const yesterdayISO = toISODate(addDays(now, -1))

  const weekStart = startOfWeek(now)
  const weekEnd = endOfWeek(now)
  const lastWeekStart = addDays(weekStart, -7)
  const lastWeekEnd = addDays(weekEnd, -7)

  const monthStart = startOfMonth(now)
  const monthEnd = endOfMonth(now)
  const lastMonthEnd = new Date(monthStart.getFullYear(), monthStart.getMonth(), 0, 23, 59, 59, 999)
  const lastMonthStart = startOfMonth(lastMonthEnd)

  const todayCount = active.filter(b => b.dateISO === todayISO).length
  const yesterdayCount = active.filter(b => b.dateISO === yesterdayISO).length

  const weekCount = active.filter(b => isWithinRange(b.dateISO, weekStart, weekEnd)).length
  const lastWeekCount = active.filter(b => isWithinRange(b.dateISO, lastWeekStart, lastWeekEnd)).length

  const monthRevenue = confirmed
    .filter(b => isWithinRange(b.dateISO, monthStart, monthEnd))
    .reduce((sum, b) => sum + (Number(b.total) || 0), 0)
  const lastMonthRevenue = confirmed
    .filter(b => isWithinRange(b.dateISO, lastMonthStart, lastMonthEnd))
    .reduce((sum, b) => sum + (Number(b.total) || 0), 0)

  const monthCancellations = cancelled
    .filter(b => isWithinRange(b.dateISO, monthStart, monthEnd))
    .length
  const lastMonthCancellations = cancelled
    .filter(b => isWithinRange(b.dateISO, lastMonthStart, lastMonthEnd))
    .length

  return {
    todayCount,
    todayDelta: formatDiff(todayCount, yesterdayCount),
    weekCount,
    weekDelta: formatDiff(weekCount, lastWeekCount),
    monthRevenue,
    monthRevenueDelta: formatMoneyDiff(monthRevenue, lastMonthRevenue),
    monthCancellations,
    monthCancellationsDelta: formatDiff(monthCancellations, lastMonthCancellations),
  }
}

export function groupWeekEvents(bookings: Booking[], weekAnchor: Date, days: Date[]): Record<number, Booking[]> {
  const result: Record<number, Booking[]> = {}
  const weekStart = startOfWeek(weekAnchor)
  const weekEnd = endOfWeek(weekAnchor)

  for (const b of bookings) {
    if (b.status === 'cancelled') continue
    if (!isWithinRange(b.dateISO, weekStart, weekEnd)) continue

    const idx = days.findIndex(d => toISODate(d) === b.dateISO)
    if (idx < 0) continue
    if (!result[idx]) result[idx] = []
    result[idx].push(b)
  }

  return result
}

export function getHourBounds(weekEventsByDay: Record<number, Booking[]>): HourBounds {
  let startHour = DEFAULT_HOUR_START
  let endHour = DEFAULT_HOUR_END

  for (const dayBookings of Object.values(weekEventsByDay)) {
    for (const b of dayBookings) {
      const startMin = timeToMinutes(b.time || '00:00')
      const endMin = b.endTime
        ? timeToMinutes(b.endTime)
        : startMin + (Number(b.durationMin) || 60)
      startHour = Math.min(startHour, Math.floor(startMin / 60))
      endHour = Math.max(endHour, Math.ceil(endMin / 60))
    }
  }

  return {
    startHour: Math.max(0, startHour),
    endHour: Math.min(24, endHour),
  }
}

export function getHours(bounds: HourBounds): string[] {
  return Array.from(
    { length: bounds.endHour - bounds.startHour },
    (_, i) => `${String(bounds.startHour + i).padStart(2, '0')}:00`,
  )
}

export function getEventGeometry(b: Booking, hourBounds: HourBounds): { top: number; height: number } {
  const startMin = timeToMinutes(b.time || '00:00')
  const endMin = b.endTime
    ? timeToMinutes(b.endTime)
    : startMin + (Number(b.durationMin) || 60)
  const hourStartMin = hourBounds.startHour * 60
  const top = ((startMin - hourStartMin) / 60) * HOUR_HEIGHT
  const height = Math.max(24, ((endMin - startMin) / 60) * HOUR_HEIGHT)
  return { top, height }
}

export function getUpcomingBookings(bookings: Booking[], now = new Date()): Booking[] {
  const todayISO = toISODate(now)
  return bookings
    .filter(b => b.dateISO >= todayISO && b.status !== 'cancelled')
    .sort((a, b) => {
      const byDate = (a.dateISO || '').localeCompare(b.dateISO || '')
      if (byDate !== 0) return byDate
      return (a.time || '').localeCompare(b.time || '')
    })
    .slice(0, 5)
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/profile/AppearanceCard.tsx' <<'QUALITY_REFACTOR_FILE'
import { Card, Field } from '../../components/UI'
import type { Lang, Theme } from '../../types'

interface AppearanceCardProps {
  lang: Lang
  theme: Theme
  onThemeChange: (theme: Theme) => void
}

export default function AppearanceCard({ lang, theme, onThemeChange }: AppearanceCardProps) {
  return (
    <Card className="mb-6">
      <h3 className="mb-4">{lang === 'ru' ? 'Внешний вид' : 'Appearance'}</h3>
      <Field label={lang === 'ru' ? 'Тема' : 'Theme'}>
        <select
          className="select"
          value={theme}
          onChange={(e) => onThemeChange(e.target.value as Theme)}
        >
          <option value="dark">{lang === 'ru' ? 'Тёмная' : 'Dark'}</option>
          <option value="light">{lang === 'ru' ? 'Светлая' : 'Light'}</option>
        </select>
      </Field>
    </Card>
  )
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/profile/ProfileFieldsCard.tsx' <<'QUALITY_REFACTOR_FILE'
import type { ChangeEvent } from 'react'
import { Avatar, Card, Field } from '../../components/UI'
import { useT } from '../../i18n/SettingsContext'
import type { Lang } from '../../types'
import type { ProfileFormValues } from './profileTypes'
import { getInitials } from './profileUtils'

interface ProfileFieldsCardProps {
  form: ProfileFormValues
  lang: Lang
  onFieldChange: (key: keyof ProfileFormValues) => (e: ChangeEvent<HTMLInputElement | HTMLTextAreaElement | HTMLSelectElement>) => void
  onLangChange: (lang: Lang) => void
}

export default function ProfileFieldsCard({ form, lang, onFieldChange, onLangChange }: ProfileFieldsCardProps) {
  const t = useT()

  return (
    <Card className="mb-6">
      <h3 className="mb-4">{t('profile.section.profile')}</h3>
      <div className="flex flex-gap-4 mb-6" style={{ alignItems: 'center' }}>
        <Avatar initials={getInitials(form.displayName || form.fullName || '?')} size={64} />
        <div>
          <div style={{ fontWeight: 600 }}>{form.displayName || form.fullName || '—'}</div>
          <div className="text-muted mt-2" style={{ fontSize: 13 }}>{form.email || ''}</div>
        </div>
      </div>

      <div className="grid grid-2">
        <Field label={t('profile.field.fullName')}><input className="input" value={form.fullName} onChange={onFieldChange('fullName')} /></Field>
        <Field label={t('profile.field.displayName')}><input className="input" value={form.displayName} onChange={onFieldChange('displayName')} /></Field>
        <Field label={t('profile.field.email')}><input className="input" value={form.email} onChange={onFieldChange('email')} /></Field>
        <Field label={t('profile.field.phone')}><input className="input" value={form.phone} onChange={onFieldChange('phone')} /></Field>
        <Field label={t('profile.field.timezone')}>
          <select className="select" value={form.timezone} onChange={onFieldChange('timezone')}>
            <option>Europe/Moscow (GMT+3)</option>
            <option>America/New_York (GMT-4)</option>
            <option>Europe/London (GMT+1)</option>
          </select>
        </Field>
        <Field label={t('profile.field.language')}>
          <select
            className="select"
            value={lang}
            onChange={(e) => onLangChange(e.target.value as Lang)}
          >
            <option value="en">English</option>
            <option value="ru">Русский</option>
          </select>
        </Field>
      </div>

      <Field label={t('profile.field.bio')}>
        <textarea className="textarea" value={form.bio} onChange={onFieldChange('bio')} />
      </Field>
    </Card>
  )
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/profile/WorkingHoursCard.tsx' <<'QUALITY_REFACTOR_FILE'
import { Card } from '../../components/UI'
import { useT } from '../../i18n/SettingsContext'
import type { WorkingHours } from '../../types'
import WorkingHoursEditor from './WorkingHoursEditor'

interface WorkingHoursCardProps {
  value: WorkingHours
  onChange: (next: WorkingHours) => void
}

export default function WorkingHoursCard({ value, onChange }: WorkingHoursCardProps) {
  const t = useT()

  return (
    <Card className="mb-6">
      <h3 className="mb-4">{t('profile.workingHours')}</h3>
      <p className="text-muted mb-4" style={{ fontSize: 13 }}>{t('profile.workingHoursHint')}</p>
      <WorkingHoursEditor value={value} onChange={onChange} />
    </Card>
  )
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/profile/WorkingHoursEditor.tsx' <<'QUALITY_REFACTOR_FILE'
import { useT } from '../../i18n/SettingsContext'
import { DAY_KEYS, type DayKey, type DayHours, type WorkingHours } from '../../types'

interface WorkingHoursEditorProps {
  value: WorkingHours
  onChange: (next: WorkingHours) => void
}

export default function WorkingHoursEditor({ value, onChange }: WorkingHoursEditorProps) {
  const t = useT()

  // Last non-null window per day — restored when the user re-enables a day they toggled off.
  // Falls back to 09:00-18:00 for never-set days.
  const fallback: DayHours = { start: '09:00', end: '18:00' }

  const updateDay = (key: DayKey, next: DayHours | null) => {
    onChange({ ...value, [key]: next })
  }

  return (
    <div style={{ display: 'flex', flexDirection: 'column', gap: 8 }}>
      {DAY_KEYS.map((key) => {
        const day = value[key]
        const enabled = day != null
        const eff = day ?? fallback
        return (
          <div key={key} style={{
            display: 'grid',
            gridTemplateColumns: '110px auto 1fr 1fr',
            alignItems: 'center',
            gap: 12,
          }}>
            <label className="flex flex-gap-2" style={{ alignItems: 'center', cursor: 'pointer' }}>
              <input
                type="checkbox"
                checked={enabled}
                onChange={(e) => updateDay(key, e.target.checked ? eff : null)}
              />
              <span style={{ fontWeight: 500 }}>{t(`day.${key}` as Parameters<typeof t>[0])}</span>
            </label>
            <span className="text-muted" style={{ fontSize: 12 }}>
              {enabled ? '' : t('profile.dayOff')}
            </span>
            <input
              className="input mono"
              type="time"
              value={eff.start}
              disabled={!enabled}
              onChange={(e) => updateDay(key, { ...eff, start: e.target.value })}
            />
            <input
              className="input mono"
              type="time"
              value={eff.end}
              disabled={!enabled}
              onChange={(e) => updateDay(key, { ...eff, end: e.target.value })}
            />
          </div>
        )
      })}
    </div>
  )
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/profile/profileTypes.ts' <<'QUALITY_REFACTOR_FILE'
import type { WorkingHours } from '../../types'

export interface ProfileFormValues {
  fullName: string
  displayName: string
  email: string
  phone: string
  timezone: string
  bio: string
  workingHours: WorkingHours
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/profile/profileUtils.ts' <<'QUALITY_REFACTOR_FILE'
import { DAY_KEYS, type WorkingHours } from '../../types'
import type { User } from '../../types'
import type { ProfileFormValues } from './profileTypes'

export const DEFAULT_WORKING_HOURS: WorkingHours = {
  mon: { start: '09:00', end: '18:00' },
  tue: { start: '09:00', end: '18:00' },
  wed: { start: '09:00', end: '18:00' },
  thu: { start: '09:00', end: '18:00' },
  fri: { start: '09:00', end: '18:00' },
}

/**
 * Backwards-compat: old User.workingHours was {start, end} (one window for all days).
 * Spread into Mon-Fri so existing users don't lose data on first edit.
 */
export function normalizeWorkingHours(wh: WorkingHours | { start?: string; end?: string } | undefined): WorkingHours {
  if (!wh) return DEFAULT_WORKING_HOURS

  const legacy = wh as { start?: string; end?: string }
  if (typeof legacy.start === 'string' && typeof legacy.end === 'string') {
    const w = { start: legacy.start, end: legacy.end }
    return { mon: w, tue: w, wed: w, thu: w, fri: w }
  }

  const newShape = wh as WorkingHours
  // Recovery: if every day is null or missing (e.g. user accidentally disabled
  // all days, or a buggy save wiped the object), restore defaults so they don't
  // end up with no availability at all.
  const hasAnyDay = DAY_KEYS.some(k => newShape[k])
  if (!hasAnyDay) return DEFAULT_WORKING_HOURS

  // Fill in missing (undefined) days from DEFAULT_WORKING_HOURS so partially-saved
  // profiles show all days the server actually treats as working. Explicit `null`
  // stays — that's the user's intent ("day off").
  const filled: WorkingHours = { ...newShape }
  for (const k of DAY_KEYS) {
    if (!(k in filled)) filled[k] = DEFAULT_WORKING_HOURS[k] ?? null
  }
  return filled
}

export function getInitials(name: string): string {
  return name.trim().split(/\s+/).slice(0, 2).map(w => w[0]?.toUpperCase() || '').join('') || '?'
}

export function getInitialProfileForm(user: User | null): ProfileFormValues {
  return {
    fullName: user?.name || '',
    displayName: user?.displayName || user?.name?.split(' ')[0] || '',
    email: user?.email || '',
    phone: user?.phone || '',
    timezone: user?.timezone || 'Europe/Moscow (GMT+3)',
    bio: user?.bio || '',
    workingHours: normalizeWorkingHours(user?.workingHours),
  }
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/services/ServicesGrid.tsx' <<'QUALITY_REFACTOR_FILE'
import type { MouseEvent } from 'react'
import { Card, Pill } from '../../components/UI'
import EmptyState from '../../components/EmptyState'
import { loc } from '../../data/mock'
import { useT, useSettings } from '../../i18n/SettingsContext'
import type { Service } from '../../types'
import type { ServiceFilterItem } from './servicesTypes'

interface ServicesGridProps {
  services: Service[]
  filters: ServiceFilterItem[]
  activeFilter: string
  isEmptySearch: boolean
  busyId: string | null
  onFilterChange: (value: string) => void
  onEdit: (service: Service) => void
  onDelete: (service: Service) => void
}

export default function ServicesGrid({
  services,
  filters,
  activeFilter,
  isEmptySearch,
  busyId,
  onFilterChange,
  onEdit,
  onDelete,
}: ServicesGridProps) {
  const t = useT()
  const { lang } = useSettings()

  return (
    <div className="services-layout">
      <aside className="services-filters">
        <div className="filter-label">{t('services.filters')}</div>
        {filters.map(f => (
          <button
            key={f.value}
            className={`filter-item ${activeFilter === f.value ? 'active' : ''}`}
            onClick={() => onFilterChange(f.value)}
          >
            <span>{f.label}</span>
            <span className="count">{f.count}</span>
          </button>
        ))}
      </aside>

      <div>
        {isEmptySearch ? (
          <EmptyState illustration="search" title={t('services.search.empty')} />
        ) : (
          <div className="services-grid">
            {services.map((service) => (
              <ServiceCard
                key={service.id}
                service={service}
                busy={busyId === service.id}
                onEdit={onEdit}
                onDelete={onDelete}
              />
            ))}
          </div>
        )}
      </div>
    </div>
  )
}

function ServiceCard({
  service,
  busy,
  onEdit,
  onDelete,
}: {
  service: Service
  busy: boolean
  onEdit: (service: Service) => void
  onDelete: (service: Service) => void
}) {
  const t = useT()
  const { lang } = useSettings()

  const stopAndRun = (e: MouseEvent<HTMLButtonElement>, action: () => void) => {
    e.preventDefault()
    e.stopPropagation()
    action()
  }

  return (
    <Card
      as="link"
      to={`/services/${service.id}`}
      interactive
      style={{
        position: 'relative',
        ...(service.tone === 'accent' ? { borderColor: 'var(--accent-ring)' } : null),
      }}
    >
      <div className="service-actions">
        <button
          type="button"
          onClick={(e) => stopAndRun(e, () => onEdit(service))}
          className="btn-text"
          style={{ fontSize: 12, padding: '2px 6px' }}
        >
          {t('services.action.edit')}
        </button>
        <button
          type="button"
          onClick={(e) => stopAndRun(e, () => onDelete(service))}
          disabled={busy}
          className="btn-text"
          style={{ fontSize: 12, padding: '2px 6px', color: 'var(--danger)' }}
        >
          {busy ? t('bookings.deleting') : t('services.action.delete')}
        </button>
      </div>

      <div className="flex-between mb-4">
        <Pill tone={service.tone}>{loc(service.tag, lang)}</Pill>
        <span className="mono text-muted" style={{ fontSize: 12 }}>{service.duration} {t('services.minutes')}</span>
      </div>
      <h3 className="mb-2" style={{ paddingRight: 80 }}>{loc(service.name, lang)}</h3>
      <p className="text-muted line-clamp-3" style={{ fontSize: 13 }}>{loc(service.description, lang)}</p>
      <div className="text-accent mono mt-auto" style={{ fontSize: 16, fontWeight: 600, paddingTop: 'var(--s-6)' }}>${service.price}</div>
    </Card>
  )
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/services/ServicesHeader.tsx' <<'QUALITY_REFACTOR_FILE'
import { Button } from '../../components/UI'
import { useT } from '../../i18n/SettingsContext'

interface ServicesHeaderProps {
  onCreate: () => void
}

export default function ServicesHeader({ onCreate }: ServicesHeaderProps) {
  const t = useT()

  return (
    <div className="flex-between mb-6">
      <div>
        <h1>{t('services.title')}</h1>
        <p className="subtitle mt-2">{t('services.subtitle')}</p>
      </div>
      <Button variant="ghost" onClick={onCreate}>{t('services.add')}</Button>
    </div>
  )
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/services/ServicesSearch.tsx' <<'QUALITY_REFACTOR_FILE'
import SearchBox from '../../components/SearchBox'
import { useT } from '../../i18n/SettingsContext'

interface ServicesSearchProps {
  query: string
  onQueryChange: (query: string) => void
}

export default function ServicesSearch({ query, onQueryChange }: ServicesSearchProps) {
  const t = useT()

  return (
    <SearchBox
      value={query}
      onChange={onQueryChange}
      placeholder={t('services.search.placeholder')}
    />
  )
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/services/ServicesState.tsx' <<'QUALITY_REFACTOR_FILE'
import { Button } from '../../components/UI'
import EmptyState from '../../components/EmptyState'
import { SkeletonCardGrid } from '../../components/Skeleton'
import { useT } from '../../i18n/SettingsContext'

export function ServicesError({ error }: { error: string }) {
  return (
    <div className="card" style={{ borderColor: 'rgba(248,113,113,0.32)', color: 'var(--danger)' }}>
      {error}
    </div>
  )
}

export function ServicesSkeleton() {
  return <SkeletonCardGrid />
}

export function EmptyServicesState({ onCreate }: { onCreate: () => void }) {
  const t = useT()

  return (
    <EmptyState
      illustration="services"
      title={t('services.empty')}
      action={<Button onClick={onCreate}>{t('services.add')}</Button>}
    />
  )
}
QUALITY_REFACTOR_FILE

write_file 'src/pages/services/servicesTypes.ts' <<'QUALITY_REFACTOR_FILE'
import type { Service } from '../../types'

// editing state: null = closed, {__new:true} = create, Service = edit
export type EditingState = Service | { __new: true } | null

export interface ServiceFilterItem {
  value: string
  label: string
  count: number
}

export const isEditingService = (editing: EditingState): editing is Service =>
  editing !== null && !('__new' in editing)
QUALITY_REFACTOR_FILE

write_file 'src/pages/services/servicesUtils.ts' <<'QUALITY_REFACTOR_FILE'
import { loc } from '../../data/mock'
import type { Lang, Service } from '../../types'
import type { ServiceFilterItem } from './servicesTypes'

export function matchesServiceQuery(service: Service, query: string, lang: Lang): boolean {
  if (!query) return true
  const haystack = [
    loc(service.name, lang),
    loc(service.description, lang),
    loc(service.tag, lang),
    service.name?.en, service.name?.ru,
    service.description?.en, service.description?.ru,
    service.tag?.en, service.tag?.ru,
  ].filter(Boolean).join(' ').toLowerCase()
  return haystack.includes(query.toLowerCase())
}

export function buildServiceFilters(
  services: Service[],
  query: string,
  lang: Lang,
  allLabel: string,
): ServiceFilterItem[] {
  const matchedAll = services.filter(s => matchesServiceQuery(s, query, lang))
  const seen = new Map<string, Service['tag']>()

  for (const s of services) {
    const key = s.tag?.en
    if (key && !seen.has(key)) seen.set(key, s.tag)
  }

  return [
    { value: 'all', label: allLabel, count: matchedAll.length },
    ...[...seen.entries()].map(([key, tag]) => ({
      value: key,
      label: loc(tag, lang),
      count: matchedAll.filter(s => s.tag?.en === key).length,
    })),
  ]
}

export function filterServices(
  services: Service[],
  activeTag: string,
  query: string,
  lang: Lang,
): Service[] {
  let list = services
  if (activeTag !== 'all') list = list.filter(s => s.tag?.en === activeTag)
  if (query) list = list.filter(s => matchesServiceQuery(s, query, lang))
  return list
}
QUALITY_REFACTOR_FILE

write_file 'tests/booking-detail-utils.test.mjs' <<'QUALITY_REFACTOR_FILE'
import { describe, expect, it } from 'vitest'
import {
  formatBookingDate,
  getBookingRef,
  getBookingTimeRange,
  getStatusTone,
} from '../src/pages/booking-detail/bookingDetailUtils.ts'

const booking = {
  id: 7,
  providerId: 1,
  customerId: 1,
  dateISO: '2099-06-16',
  time: '10:00',
  endTime: '11:00',
  durationMin: 60,
  service: 'English lesson',
  total: 100,
  status: 'confirmed',
  withName: 'Anna Smith',
  initials: 'AS',
  customerEmail: 'anna@example.com',
  customerPhone: null,
  notes: null,
  createdAt: '2099-01-01',
}

describe('bookingDetailUtils', () => {
  it('formats booking reference with zero padding', () => {
    expect(getBookingRef(7)).toBe('SLT-0007')
    expect(getBookingRef('42')).toBe('SLT-0042')
  })

  it('formats time range with optional end time', () => {
    expect(getBookingTimeRange(booking)).toBe('10:00 – 11:00')
    expect(getBookingTimeRange({ ...booking, endTime: undefined })).toBe('10:00')
  })

  it('maps booking status to pill tone', () => {
    expect(getStatusTone('confirmed')).toBe('success')
    expect(getStatusTone('cancelled')).toBe('danger')
    expect(getStatusTone('pending')).toBe('accent')
  })

  it('formats date and handles missing value', () => {
    expect(formatBookingDate(undefined, 'en')).toBe('')
    expect(formatBookingDate('2099-06-16', 'en')).toContain('2099')
  })
})
QUALITY_REFACTOR_FILE

write_file 'tests/bookings-utils.test.mjs' <<'QUALITY_REFACTOR_FILE'
import { describe, expect, it } from 'vitest'
import {
  addMinutesHHMM,
  annotateBookings,
  filterBookings,
  formatDateShort,
  groupBookingsByStatus,
  sortBookings,
} from '../src/pages/bookings/bookingsUtils.ts'

const baseBooking = {
  id: '1',
  providerId: 1,
  customerId: 1,
  dateISO: '2099-06-16',
  time: '10:00',
  endTime: '11:00',
  durationMin: 60,
  service: 'English lesson',
  total: 100,
  status: 'confirmed',
  withName: 'Anna Smith',
  initials: 'AS',
  customerEmail: 'anna@example.com',
  customerPhone: null,
  notes: null,
  createdAt: '2099-01-01',
}

describe('bookingsUtils', () => {
  it('sorts bookings by date and time', () => {
    const sorted = sortBookings([
      { ...baseBooking, id: '3', dateISO: '2099-06-17', time: '09:00' },
      { ...baseBooking, id: '1', dateISO: '2099-06-16', time: '11:00' },
      { ...baseBooking, id: '2', dateISO: '2099-06-16', time: '10:00' },
    ])

    expect(sorted.map(b => b.id)).toEqual(['2', '1', '3'])
  })

  it('groups bookings into upcoming, past and cancelled', () => {
    const annotated = annotateBookings([
      { ...baseBooking, id: '1', dateISO: '2099-06-16', status: 'confirmed' },
      { ...baseBooking, id: '2', dateISO: '2099-06-15', status: 'confirmed' },
      { ...baseBooking, id: '3', dateISO: '2099-06-17', status: 'cancelled' },
    ])

    const groups = groupBookingsByStatus(annotated, '2099-06-16')

    expect(groups.upcoming.map(x => x.b.id)).toEqual(['1'])
    expect(groups.past.map(x => x.b.id)).toEqual(['2'])
    expect(groups.cancelled.map(x => x.b.id)).toEqual(['3'])
  })

  it('filters visible bookings by customer, service, email or date', () => {
    const annotated = annotateBookings([
      { ...baseBooking, id: '1', service: 'English lesson', withName: 'Anna Smith' },
      { ...baseBooking, id: '2', service: 'Math lesson', withName: 'Bob Brown', customerEmail: 'bob@example.com' },
    ])
    const groups = { upcoming: annotated, past: [], cancelled: [] }

    expect(filterBookings(groups, 'upcoming', 'math').map(x => x.b.id)).toEqual(['2'])
    expect(filterBookings(groups, 'upcoming', 'anna').map(x => x.b.id)).toEqual(['1'])
    expect(filterBookings(groups, 'upcoming', 'bob@example.com').map(x => x.b.id)).toEqual(['2'])
  })

  it('adds minutes to HH:MM time', () => {
    expect(addMinutesHHMM('10:30', 90)).toBe('12:00')
    expect(addMinutesHHMM('23:30', 60)).toBe('00:30')
  })

  it('formats short dates and handles missing value', () => {
    expect(formatDateShort(undefined, 'en')).toBe('—')
    expect(formatDateShort('2099-06-16', 'en')).toMatch(/Jun|16/)
  })
})
QUALITY_REFACTOR_FILE

write_file 'tests/command-palette-utils.test.mjs' <<'QUALITY_REFACTOR_FILE'
import { describe, expect, it } from 'vitest'
import { buildPaletteResults, splitResultGroups } from '../src/components/command-palette/commandPaletteUtils.ts'

const t = (key) => key === 'services.minutes' ? 'min' : key

const service = {
  id: 'svc-1',
  providerId: 1,
  tag: { en: 'lesson', ru: 'урок' },
  tone: 'accent',
  duration: 60,
  price: 100,
  name: { en: 'English lesson', ru: 'Урок английского' },
  description: { en: 'Speaking practice', ru: 'Разговорная практика' },
}

const booking = {
  id: 7,
  providerId: 1,
  customerId: 1,
  serviceId: 'svc-1',
  dateISO: '2099-06-16',
  time: '10:00',
  endTime: '11:00',
  durationMin: 60,
  service: 'English lesson',
  total: 100,
  status: 'confirmed',
  withName: 'Anna Smith',
  initials: 'AS',
  customerEmail: 'anna@example.com',
  customerPhone: '+100000000',
  notes: 'Bring workbook',
  createdAt: '2099-01-01',
}

describe('commandPaletteUtils', () => {
  it('returns no results for an empty query', () => {
    const results = buildPaletteResults({
      query: '   ',
      services: [service],
      bookings: [booking],
      lang: 'en',
      t,
    })

    expect(results).toEqual([])
  })

  it('finds services by localized service text', () => {
    const results = buildPaletteResults({
      query: 'speaking',
      services: [service],
      bookings: [],
      lang: 'en',
      t,
    })

    expect(results).toMatchObject([
      {
        id: 'service-svc-1',
        group: 'services',
        title: 'English lesson',
        to: '/services/svc-1',
      },
    ])
  })

  it('finds bookings by customer email and maps to booking detail page', () => {
    const results = buildPaletteResults({
      query: 'anna@example.com',
      services: [],
      bookings: [booking],
      lang: 'en',
      t,
    })

    expect(results).toMatchObject([
      {
        id: 'booking-7',
        group: 'bookings',
        title: 'English lesson — Anna Smith',
        to: '/bookings/7',
      },
    ])
  })

  it('splits mixed results by group', () => {
    const results = buildPaletteResults({
      query: 'english',
      services: [service],
      bookings: [booking],
      lang: 'en',
      t,
    })
    const grouped = splitResultGroups(results)

    expect(grouped.serviceItems).toHaveLength(1)
    expect(grouped.bookingItems).toHaveLength(1)
  })
})
QUALITY_REFACTOR_FILE

write_file 'tests/dashboard-utils.test.mjs' <<'QUALITY_REFACTOR_FILE'
import { describe, expect, it } from 'vitest'
import {
  calculateDashboardStats,
  getEventGeometry,
  getHourBounds,
  getHours,
  getUpcomingBookings,
  groupWeekEvents,
} from '../src/pages/dashboard/dashboardUtils.ts'
import { addDays, startOfWeek } from '../src/utils/date.ts'

const baseBooking = {
  id: 1,
  providerId: 1,
  customerId: 1,
  dateISO: '2099-06-16',
  time: '10:00',
  endTime: '11:00',
  durationMin: 60,
  service: 'Lesson',
  total: 100,
  status: 'confirmed',
  withName: 'Client',
  initials: 'C',
  customerEmail: 'client@example.com',
  customerPhone: null,
  notes: null,
  createdAt: '2099-01-01',
}

describe('dashboardUtils', () => {
  it('calculates dashboard stats for day, week, revenue and cancellations', () => {
    const now = new Date(2099, 5, 16, 12, 0)
    const bookings = [
      { ...baseBooking, id: 1, dateISO: '2099-06-16', status: 'confirmed', total: 100 },
      { ...baseBooking, id: 2, dateISO: '2099-06-17', status: 'confirmed', total: 200 },
      { ...baseBooking, id: 3, dateISO: '2099-06-18', status: 'cancelled', total: 300 },
      { ...baseBooking, id: 4, dateISO: '2099-06-09', status: 'confirmed', total: 50 },
    ]

    const stats = calculateDashboardStats(bookings, now)

    expect(stats.todayCount).toBe(1)
    expect(stats.weekCount).toBe(2)
    expect(stats.monthRevenue).toBe(350)
    expect(stats.monthCancellations).toBe(1)
  })

  it('groups active week events by day index and skips cancelled bookings', () => {
    const weekAnchor = new Date(2099, 5, 16)
    const weekStart = startOfWeek(weekAnchor)
    const days = Array.from({ length: 7 }, (_, i) => addDays(weekStart, i))
    const bookings = [
      { ...baseBooking, id: 1, dateISO: '2099-06-16', status: 'confirmed' },
      { ...baseBooking, id: 2, dateISO: '2099-06-16', status: 'cancelled' },
      { ...baseBooking, id: 3, dateISO: '2099-06-17', status: 'confirmed' },
    ]

    const grouped = groupWeekEvents(bookings, weekAnchor, days)

    expect(grouped[1].map(b => b.id)).toEqual([1])
    expect(grouped[2].map(b => b.id)).toEqual([3])
  })

  it('expands visible hours to include early and late bookings', () => {
    const bounds = getHourBounds({
      0: [
        { ...baseBooking, id: 1, time: '07:30', endTime: '08:30' },
        { ...baseBooking, id: 2, time: '20:00', endTime: '21:00' },
      ],
    })

    expect(bounds).toEqual({ startHour: 7, endHour: 21 })
    expect(getHours(bounds)).toContain('20:00')
  })

  it('returns event geometry in pixels relative to visible hour bounds', () => {
    const geometry = getEventGeometry(
      { ...baseBooking, time: '10:30', endTime: '12:00' },
      { startHour: 9, endHour: 18 },
    )

    expect(geometry.top).toBe(84)
    expect(geometry.height).toBe(84)
  })

  it('returns only upcoming non-cancelled bookings sorted by date and time', () => {
    const now = new Date(2099, 5, 16, 12, 0)
    const bookings = [
      { ...baseBooking, id: 1, dateISO: '2099-06-17', time: '12:00', status: 'confirmed' },
      { ...baseBooking, id: 2, dateISO: '2099-06-16', time: '09:00', status: 'confirmed' },
      { ...baseBooking, id: 3, dateISO: '2099-06-18', time: '10:00', status: 'cancelled' },
      { ...baseBooking, id: 4, dateISO: '2099-06-15', time: '10:00', status: 'confirmed' },
    ]

    expect(getUpcomingBookings(bookings, now).map(b => b.id)).toEqual([2, 1])
  })
})
QUALITY_REFACTOR_FILE

write_file 'tests/profile-utils.test.mjs' <<'QUALITY_REFACTOR_FILE'
import { describe, expect, it } from 'vitest'
import {
  DEFAULT_WORKING_HOURS,
  getInitialProfileForm,
  getInitials,
  normalizeWorkingHours,
} from '../src/pages/profile/profileUtils.ts'

describe('profileUtils', () => {
  it('returns default working hours for missing value', () => {
    expect(normalizeWorkingHours(undefined)).toEqual(DEFAULT_WORKING_HOURS)
  })

  it('expands legacy flat working hours to weekdays', () => {
    const normalized = normalizeWorkingHours({ start: '10:00', end: '17:00' })

    expect(normalized.mon).toEqual({ start: '10:00', end: '17:00' })
    expect(normalized.fri).toEqual({ start: '10:00', end: '17:00' })
    expect(normalized.sat).toBeUndefined()
  })

  it('keeps explicit day off and fills missing days from defaults', () => {
    const normalized = normalizeWorkingHours({ mon: null, tue: { start: '11:00', end: '15:00' } })

    expect(normalized.mon).toBeNull()
    expect(normalized.tue).toEqual({ start: '11:00', end: '15:00' })
    expect(normalized.wed).toEqual(DEFAULT_WORKING_HOURS.wed)
  })

  it('recovers defaults when all days are disabled or missing', () => {
    expect(normalizeWorkingHours({ mon: null, tue: null })).toEqual(DEFAULT_WORKING_HOURS)
  })

  it('builds initials from one or two words', () => {
    expect(getInitials('Anna Smith')).toBe('AS')
    expect(getInitials('Anna')).toBe('A')
    expect(getInitials('')).toBe('?')
  })

  it('creates initial profile form from user data', () => {
    const form = getInitialProfileForm({
      id: 1,
      email: 'anna@example.com',
      name: 'Anna Smith',
      displayName: 'Anna',
      phone: '+1000',
      timezone: 'Europe/London (GMT+1)',
      bio: 'Tutor',
      workingHours: { start: '10:00', end: '16:00' },
    })

    expect(form).toMatchObject({
      fullName: 'Anna Smith',
      displayName: 'Anna',
      email: 'anna@example.com',
      phone: '+1000',
      timezone: 'Europe/London (GMT+1)',
      bio: 'Tutor',
    })
    expect(form.workingHours.mon).toEqual({ start: '10:00', end: '16:00' })
  })
})
QUALITY_REFACTOR_FILE

write_file 'tests/services-utils.test.mjs' <<'QUALITY_REFACTOR_FILE'
import { describe, expect, it } from 'vitest'
import { buildServiceFilters, filterServices, matchesServiceQuery } from '../src/pages/services/servicesUtils.ts'
import {
  toServiceFormValues,
  toServicePayload,
  validateServiceForm,
} from '../src/components/service-form/serviceFormUtils.ts'

const t = (key) => key

const service = {
  id: 'svc-1',
  providerId: 1,
  tag: { en: 'lesson', ru: 'урок' },
  tone: 'accent',
  duration: 60,
  price: 100,
  name: { en: 'English lesson', ru: 'Урок английского' },
  description: { en: 'Speaking practice', ru: 'Разговорная практика' },
}

const secondService = {
  ...service,
  id: 'svc-2',
  tag: { en: 'consulting', ru: 'консультация' },
  name: { en: 'Career consulting', ru: 'Карьерная консультация' },
  description: { en: 'Career plan', ru: 'План карьеры' },
}

describe('servicesUtils', () => {
  it('matches service by localized text', () => {
    expect(matchesServiceQuery(service, 'speaking', 'en')).toBe(true)
    expect(matchesServiceQuery(service, 'карьеры', 'ru')).toBe(false)
  })

  it('builds filters with counts respecting query', () => {
    const filters = buildServiceFilters([service, secondService], 'career', 'en', 'All')

    expect(filters).toEqual([
      { value: 'all', label: 'All', count: 1 },
      { value: 'lesson', label: 'lesson', count: 0 },
      { value: 'consulting', label: 'consulting', count: 1 },
    ])
  })

  it('filters services by tag and query', () => {
    expect(filterServices([service, secondService], 'consulting', '', 'en').map(s => s.id)).toEqual(['svc-2'])
    expect(filterServices([service, secondService], 'all', 'english', 'en').map(s => s.id)).toEqual(['svc-1'])
  })
})

describe('serviceFormUtils', () => {
  it('maps service to form values', () => {
    expect(toServiceFormValues(service)).toMatchObject({
      tagEn: 'lesson',
      tagRu: 'урок',
      tone: 'accent',
      duration: 60,
      price: 100,
      nameEn: 'English lesson',
      nameRu: 'Урок английского',
      descEn: 'Speaking practice',
      descRu: 'Разговорная практика',
    })
  })

  it('maps form values to trimmed payload', () => {
    const payload = toServicePayload({
      tagEn: ' lesson ',
      tagRu: ' урок ',
      tone: 'muted',
      duration: '45',
      price: '120',
      nameEn: ' Name ',
      nameRu: ' Имя ',
      descEn: ' Desc ',
      descRu: ' Описание ',
    })

    expect(payload).toEqual({
      tag: { en: 'lesson', ru: 'урок' },
      tone: 'muted',
      duration: 45,
      price: 120,
      name: { en: 'Name', ru: 'Имя' },
      description: { en: 'Desc', ru: 'Описание' },
    })
  })

  it('validates required fields and numeric constraints', () => {
    const errors = validateServiceForm({
      tagEn: '', tagRu: '', tone: 'muted', duration: 0, price: -1,
      nameEn: '', nameRu: '', descEn: '', descRu: '',
    }, t)

    expect(errors).toMatchObject({
      tagEn: 'validation.required',
      duration: 'validation.positiveNumber',
      price: 'validation.nonNegativeNumber',
    })
  })
})
QUALITY_REFACTOR_FILE

echo "Installed quality refactor."
echo "Backup directory: $BACKUP_DIR"
echo ""
echo "Required runtime after dependency update: Node.js >=22"
echo ""
echo "Run checks:"
echo "  npm ci"
echo "  npm audit"
echo "  npm test"
echo "  npm run build"
