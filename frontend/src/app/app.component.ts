import { Component, DestroyRef, inject, signal } from '@angular/core';
import { takeUntilDestroyed } from '@angular/core/rxjs-interop';
import { finalize } from 'rxjs';
import { HelloService } from './services/hello.service';

@Component({
  selector: 'app-root',
  standalone: true,
  templateUrl: './app.component.html'
})
export class AppComponent {
  private readonly helloService = inject(HelloService);
  private readonly destroyRef = inject(DestroyRef);

  readonly loading = signal(false);
  readonly message = signal('');
  readonly error = signal('');
  readonly receivedAt = signal('');

  loadMessage(): void {
    if (this.loading()) return;
    this.loading.set(true);
    this.message.set('');
    this.error.set('');
    this.receivedAt.set('');

    this.helloService.getMessage().pipe(
      takeUntilDestroyed(this.destroyRef),
      finalize(() => this.loading.set(false))
    ).subscribe({
      next: response => {
        this.message.set(response.message);
        this.receivedAt.set(new Date().toLocaleTimeString('vi-VN'));
      },
      error: () => this.error.set('Chưa nhận được phản hồi. Hãy kiểm tra backend đang chạy ở cổng 8080, rồi thử lại.')
    });
  }
}
