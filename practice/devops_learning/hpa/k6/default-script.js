import http from 'k6/http';
import { check, sleep } from 'k6';

export const options = {
  stages: [
    { duration: '4m', target: 100},
    { duration: '4m', target: 100},
    { duration: '2m', target: 0},
  ],
  thresholds: {
    http_req_duration:['p(95)<500'],
    http_req_failed:['rate<0.01'],
    checks:['rate>0.99'],
  }
};

export default function () {
    const res = http.get('http://tester.lucky-gun.com');
    
    check(res, {
      'status is 200' : (r) => r.status === 200,
      'response time < 300ms' : (r) => r.timings.duration < 300,
    });    

}
