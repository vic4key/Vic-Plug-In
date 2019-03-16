// 002 u_dll_process_viewer
// 04 apr 2007

// -- (C) Felix John COLIBRI 2007
// -- documentation: http://www.felix-colibri.com

(*$r+*)

unit u_dll_process_viewer;

interface

uses
  Windows, Messages, SysUtils, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, ComCtrls, ExtCtrls, XPMan;

type
  TDLLPV = class(TForm)
    Panel1: TPanel;
    PageControl1: TPageControl;
    display__: TTabSheet;
    detail_: TTabSheet;
    Memo1: TMemo;
    Panel2: TPanel;
    process_listbox_: TListBox;
    create_: TButton;
    Panel6: TPanel;
    Panel8: TPanel;
    process_memo_: TMemo;
    PageControl2: TPageControl;
    dll_: TTabSheet;
    mapped_files_: TTabSheet;
    Panel4: TPanel;
    Panel5: TPanel;
    module_count_label_: TLabel;
    sort_dll_: TCheckBox;
    module_listbox_: TListBox;
    Splitter1: TSplitter;
    module_memo_: TMemo;
    Panel7: TPanel;
    Panel9: TPanel;
    memory_mapped_file_listbox_: TListBox;
    Splitter2: TSplitter;
    memory_mapped_file_memo_: TMemo;
    build_mmf_: TCheckBox;
    Label1: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    XPManifest1: TXPManifest;
    cbOnTop: TCheckBox;
    procedure FormShow(Sender: TObject);
    procedure PageControl1Change(Sender: TObject);
    procedure cbOnTopClick(Sender: TObject);
    procedure Memo1Change(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure exit_Click(Sender: TObject);
    procedure clear_Click(Sender: TObject);
    procedure create_Click(Sender: TObject);
    procedure process_listbox_Click(Sender: TObject);
    procedure module_listbox_Click(Sender: TObject);
    procedure sort_dll_Click(Sender: TObject);
    procedure memory_mapped_file_listbox_Click(Sender: TObject);
  private
  public
    procedure Init;
  end;

    var DLLPV: TDLLPV;

  implementation
    uses u_c_log, u_c_display, u_display_hex_2
        , u_c_process_list
    ;

    {$R *.DFM}

    var g_c_process_list: c_process_list= Nil;

    procedure TDLLPV.Init;
      var l_process_index: Integer;
      begin
        g_c_process_list:= c_process_list.create_process_list('Process List');

        with g_c_process_list do
        begin
          get_nt_process_list(build_mmf_.Checked);

          process_listbox_.Items.Clear;
          for l_process_index:= 0 to f_process_count- 1 do
            with f_c_process(l_process_index) do
              process_listbox_.Items.AddObject(m_name, f_c_self);
        end; // with g_c_process_list
      end; procedure TDLLPV.Memo1Change(Sender: TObject);
begin

end;

// create_Click

procedure TDLLPV.FormCreate(Sender: TObject);
begin
  initialize_display(Memo1.Lines);
  initialize_default_log;
  Init;
  SetWindowLongA(create_.Handle,GWL_STYLE,(GetWindowLongA(create_.Handle,GWL_STYLE) or BS_FLAT));
end;

procedure TDLLPV.FormShow(Sender: TObject);
begin
  Self.cbOnTopClick(Sender);
end;

// FormCreate

procedure TDLLPV.exit_Click(Sender: TObject);
begin
  Close;
end; // exit_Click

procedure TDLLPV.cbOnTopClick(Sender: TObject);
begin
  case cbOnTop.Checked of
    True:  Self.FormStyle:= fsStayOnTop;
    False: Self.FormStyle:= fsNormal;
  end;
end;

procedure TDLLPV.clear_Click(Sender: TObject);
begin
    
end; // clear_Click

procedure TDLLPV.create_Click(Sender: TObject);
var l_process_index: Integer;
begin
  Memo1.Clear;
  g_c_process_list:= c_process_list.create_process_list('+ Process List');

  with g_c_process_list do
  begin
    get_nt_process_list(build_mmf_.Checked);

    process_listbox_.Items.Clear;
    for l_process_index:= 0 to f_process_count- 1 do
      with f_c_process(l_process_index) do
        process_listbox_.Items.AddObject(m_name, f_c_self);
  end; // with g_c_process_list
end; // create_Click

procedure TDLLPV.process_listbox_Click(Sender: TObject);
var
  l_module_index: Integer;
  l_memory_mapped_file_index: Integer;
begin
  with process_listbox_ do
    if ItemIndex>= 0
      then
        with c_process(Items.Objects[ItemIndex]), process_memo_.Lines do
        begin
          Clear;
          // display_module_list;
          Add(' Module Name: "' + m_name + '"');
          Add(' Module Path: "' + m_process_path + '"');
          Add('  ID       : '+ IntToHex(m_process_id,8));
          Add('  Priority : '+ m_process_priority);
          Add('  Time K, C, U: '+ m_kernel_time+ ' '+ m_cpu_time+ ' '+ m_user_time);

          module_count_label_.Caption:= IntToStr(m_module_count);

          module_listbox_.Items.Clear;
          module_listbox_.Sorted:= sort_dll_.Checked;

          for l_module_index:= 0 to f_module_count- 1 do
            with f_c_module(l_module_index) do
              module_listbox_.Items.AddObject(m_name, f_c_self);

          memory_mapped_file_listbox_.Items.Clear;
          for l_memory_mapped_file_index:= 0 to f_memory_mapped_file_count- 1 do
            with f_c_memory_mapped_file(l_memory_mapped_file_index) do
              memory_mapped_file_listbox_.Items.AddObject(m_name, f_c_self);
        end;
end; // process_listbox_Click

procedure TDLLPV.sort_dll_Click(Sender: TObject);
begin
  with process_listbox_ do
    if ItemIndex>= 0
      then process_listbox_Click(Nil);
end; // sort_dll_Click

procedure TDLLPV.module_listbox_Click(Sender: TObject);
begin
  with module_listbox_ do
    if ItemIndex>= 0
      then
        with c_module(Items.Objects[ItemIndex]), module_memo_.Lines do
        begin
          Clear;
          Add(' Module Name: "' + m_module_name + '"');
          Add(' Module Path: "' + m_module_path + '"');
          Add('  Base  : '+ IntToHex(Integer(m_pt_base_address),8));
          Add('  Size  : '+ IntToHex(Integer(m_image_size),8));
          Add('  Entry : '+ IntToHex(Integer(m_pt_entry_point),8));
        end;
end;

procedure TDLLPV.PageControl1Change(Sender: TObject);
begin

end;

// module_listbox_Click

procedure TDLLPV.memory_mapped_file_listbox_Click(Sender: TObject);
begin
  with memory_mapped_file_listbox_ do
    if ItemIndex>= 0
      then
        with c_memory_mapped_file(Items.Objects[ItemIndex]), memory_mapped_file_memo_.Lines do
        begin
          Clear;
          Add(m_name);
          Add('  Work Set : '+ f_integer_to_hex(Integer(m_pt_working_set)));
          Add('  Type     : '+ m_memory_type);
        end;
end; // mapped_file_listbox_Click

end.


