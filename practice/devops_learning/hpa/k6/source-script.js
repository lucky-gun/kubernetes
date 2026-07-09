// Ramp-up test (stress test) 한계확인
export const options = {

  stages: [

    { duration: '2m', target: 20 },

    { duration: '3m', target: 80 },

    { duration: '5m', target: 150 },

    { duration: '3m', target: 20 },

    { duration: '3m', target: 0 },

  ]

}
//spike Test (급격한 테스트)
export const options = {

  stages: [

    { duration: '30s', target: 300 },

    { duration: '2m', target: 300 },

    { duration: '30s', target: 0 },

  ]

}
//soak test
export const options = {

  vus:100,

  duration:'20m'

}

//smoke test
export const options = {
  vus: 1,
  duration: '10s',
};

//load test
export const options = {
  stages: [
    { duration: '2m', target: 100 },   // 2분 동안 100명까지 증가
    { duration: '5m', target: 100 },   // 5분간 100명 유지
    { duration: '2m', target: 0 },     // 2분 동안 점진적 감소
  ],
};

import http from 'k6/http';

export default function () {
  // 로그인 후 토큰 획득
  const loginRes = http.post('https://example.com/api/login', JSON.stringify({
    username: 'testuser',
    password: 'testpass',
  }), { headers: { 'Content-Type': 'application/json' } });

  const token = loginRes.json('access_token');

  // 인증된 API 호출
  http.get('https://example.com/api/data', {
    headers: { Authorization: `Bearer ${token}` },
  });
}
