import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '1m', target: 500 },    // ramp up to 500 users (all faculty accounts once)
    { duration: '2m', target: 5000 },   // ramp up to 5k users (accounts reused)
    { duration: '2m', target: 10000 },  // ramp up to 10k users (accounts reused)
    { duration: '2m', target: 0 },      // ramp down
  ],
  thresholds: {
    http_req_duration: ['p(95)<2000'],  // 95% of requests < 2s
    http_req_failed: ['rate<0.05'],     // <5% failures
  },
};

// Generate credentials for faculty only
function creds(i) {
  const j = i % 500; // cycle through 500 accounts
  return {
    email: `faculty${j + 1}@st.futminna.edu.ng`,
    password: 'staff123',
  };
}

export default function () {
  const i = (__VU - 1); // map virtual users to accounts
  const { email, password } = creds(i);

  // 1) Get login page
  let r1 = http.get('http://4.253.33.191:8069/web/login');
  check(r1, { 'login page 200': (r) => r.status === 200 });

  // 2) Post credentials
  const payload = {
    login: email,
    password: password,
    redirect: '',
  };
  let r2 = http.post('http://4.253.33.191:8069/web/login', payload, {
    headers: { 'Content-Type': 'application/x-www-form-urlencoded' },
  });
  check(r2, {
    'logged in or redirected': (r) => r.status === 200 || r.status === 302,
  });

  sleep(1);
}
