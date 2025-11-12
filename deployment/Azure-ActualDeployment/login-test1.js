import http from 'k6/http';
import { Counter, Trend } from 'k6/metrics';
import { sleep } from 'k6';

// Custom metrics
export let loginSuccess = new Counter('login_success');
export let loginFail = new Counter('login_fail');
export let requestSuccess = new Counter('request_success');
export let requestFail = new Counter('request_fail');
export let under1min = new Counter('under_1min');
export let over1min = new Counter('over_1min');
export let latency = new Trend('latency', true);
export let logoutSuccess = new Counter('logout_success');
export let logoutFail = new Counter('logout_fail');

export const options = {
  stages: [
    { duration: '30s', target: 100 },   // ramp up to 100 users
    { duration: '1m', target: 100 },    // hold steady at 100
    { duration: '30s', target: 0 },     // ramp down
  ],
};

function creds(i) {
  const j = i % 500;
  return {
    email: `student${j + 1}@st.futminna.edu.ng`,
    password: 'student123',
  };
}

// Extract CSRF token from login page HTML
function extractCSRF(html) {
  if (!html) return null;
  const match = html.match(/name="csrf_token"[^>]*value="([^"]+)"/i);
  return match ? match[1] : null;
}

export default function () {
  const i = (__VU - 1);
  const { email, password } = creds(i);

  const jar = new http.CookieJar();

  // 1) Get login page
  let r1 = http.get('http://4.253.40.132:8069/web/login', { jar });
  if (r1.status !== 200 || !r1.body) {
    requestFail.add(1);
    loginFail.add(1);
    return;
  }
  requestSuccess.add(1);

  const csrf = extractCSRF(r1.body);
  if (!csrf) {
    requestFail.add(1);
    loginFail.add(1);
    return;
  }

  // 2) Post credentials with cookies + CSRF
  const form = {
    login: email,
    password: password,
    redirect: '',
    csrf_token: csrf,
  };

  const payload = Object.entries(form)
    .map(([k, v]) => `${encodeURIComponent(k)}=${encodeURIComponent(v)}`)
    .join('&');

  const start = Date.now();
  let r2 = http.post('http://4.253.40.132:8069/web/login', payload, {
    jar,
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
    redirects: 0,
  });
  const duration = Date.now() - start;
  latency.add(duration);

  if (r2.status === 200 || r2.status === 302) {
    loginSuccess.add(1);
    requestSuccess.add(1);

    // Simulate session duration (max 2 minutes)
    sleep(Math.random() * 120); // random between 0–120s

    // 3) Logout
    let r3 = http.get('http://4.253.40.132:8069/web/logout', { jar });
    if (r3.status === 200 || r3.status === 302) {
      logoutSuccess.add(1);
    } else {
      logoutFail.add(1);
    }

  } else {
    loginFail.add(1);
    requestFail.add(1);
  }

  if (duration < 60000) {
    under1min.add(1);
  } else {
    over1min.add(1);
  }
}
