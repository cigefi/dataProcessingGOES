function [] = mailNoti(msg)
    %RECIPIENTS = {'villegas.roberto@hotmail.com','rodrigo.castillorodriguez@ucr.ac.cr'};
    RECIPIENTS = {'villegas.roberto@hotmail.com'};
    subject = '[MATLAB][GOES]';
    msj = strcat({'Execution status: '},msg);
    mailsender(RECIPIENTS,subject,msj);
end