import { inject, Injectable } from '@angular/core';
import { HttpClient } from '@angular/common/http';
import { timeout } from 'rxjs';

export interface HelloResponse {
  message: string;
}

@Injectable({ providedIn: 'root' })
export class HelloService {
  private readonly http = inject(HttpClient);

  getMessage() {
    return this.http.get<HelloResponse>('/api/hello').pipe(timeout(10000));
  }
}
