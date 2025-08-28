<?php

namespace App\Notifications; 
use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;

class ResetPasswordNotification extends Notification
{
    use Queueable;

    protected $code;

    /**
     * Create a new notification instance.
     *
     * @param  string  $code
     * @return void
     */
    public function __construct($code)
    {
        $this->code = $code;
    }

    /**
     * Get the notification's delivery channels.
     *
     * @param  mixed  $notifiable
     * @return array
     */
    public function via($notifiable)
    {
        return ['mail'];
    }

    /**
     * Get the mail representation of the notification.
     *
     * @param  mixed  $notifiable
     * @return \Illuminate\Notifications\Messages\MailMessage
     */
    public function toMail($notifiable)
{
    $code = $this->code;
    //$resetUrl = url(config('app.url').route('password.reset', $code, false));

    return (new MailMessage)
        ->subject('Réinitialisation du mot de passe avec le code de confirmation')
        ->view(
            'emails.password_reset',
            [
                'code' => $code
                //'resetUrl' => $resetUrl
            ]
        );
}


}