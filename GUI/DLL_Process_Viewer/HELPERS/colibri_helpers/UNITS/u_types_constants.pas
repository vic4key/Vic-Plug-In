// 016 u_types_constants
// 23 jan 2007

// -- (C) Felix John COLIBRI 2007
// -- documentation: http://www.felix-colibri.com

(*$r+*)

unit u_types_constants;
  interface

    const k_word_max= 65534;

    type t_pt_byte= ^Byte;
         t_pt_integer= ^Integer;

         t_bytes= array[0..0] of Byte;
         t_pt_bytes= ^t_bytes;
         t_pt_word= ^Word;

         t_oa_bytes= array of Byte;

         t_handle_procedure= procedure(p_pt: Pointer);
         t_set_or_char= Set Of Char;

         t_byte_date= packed record
                               m_day, m_month, m_year: byte;
                             end;
         t_date_4= packed record
                            m_day, m_month: byte;
                            m_year: Integer;
                          end;


  implementation

    begin
    end.


































