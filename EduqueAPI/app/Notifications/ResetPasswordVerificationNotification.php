<?php

namespace App\Notifications;

use Illuminate\Bus\Queueable;
use Illuminate\Contracts\Queue\ShouldQueue;
use Illuminate\Notifications\Messages\MailMessage;
use Illuminate\Notifications\Notification;
use Otp;
class ResetPasswordVerificationNotification extends Notification
{
    use Queueable;
    public $message;
    public $subject;
    public $fromEmail;
    public $mailer;
    private $otp;
   

    /**
     * Create a new notification instance.
     */
    public function __construct($otp)
    {
        $this->message = "Utilisez le code ci-dessous pour réinitialiser votre mot de passe.";
        $this->subject = "Réinitialisation du mot de passe.";
        $this->fromEmail = "fiaboeirene@gmail.com";
        $this->mailer = "smtp";
        $this->otp = $otp;
    }

    /**
     * Get the notification's delivery channels.
     *
     * @return array<int, string>
     */
    public function via(object $notifiable): array
    {
        return ['mail'];
    }

    /**
     * Get the mail representation of the notification.
     */
    public function toMail(object $notifiable): MailMessage
    {
        //$otp = $this->otp->generate($notifiable->email,6,60);
        return (new MailMessage)
        ->mailer('smtp')
        ->subject($this->subject)
        ->greeting('Hello'.$notifiable->first_name)
        ->line($this->message)
        ->line('code: '. $this->otp->code);
    }

    /**
     * Get the array representation of the notification.
     *
     * @return array<string, mixed>
     */
    public function toArray(object $notifiable): array
    {
        return [
            //
        ];
    }
}
