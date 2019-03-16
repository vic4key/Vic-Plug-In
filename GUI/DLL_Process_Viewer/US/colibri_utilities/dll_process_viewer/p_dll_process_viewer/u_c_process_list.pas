// 002 u_c_process_list
// 04 apr 2007

// -- (C) Felix John COLIBRI 2007
// -- documentation: http://www.felix-colibri.com

// -- for NT Os (not win95 etc)
// --   => uses psApi (import unit in Sources/Rtl/Win)

(*$r+*)

unit u_c_process_list;
  interface
    uses Classes, Windows, u_c_basic_object;

    type c_module= // one "module" == DLL
                    Class(c_basic_object)
                      // -- m_name:
                      m_module_name: String;
                      m_module_path: String;

                      m_pt_base_address: Pointer;
                      m_image_size: DWORD;
                      m_pt_entry_point: Pointer;

                      Constructor create_module(p_name: String);
                      function f_c_self: c_module;
                      function f_display_module: String;
                      Destructor Destroy; Override;
                    end; // c_module

         c_memory_mapped_file= // one "memory_mapped_file"
                    Class(c_basic_object)
                      // -- m_name:
                      m_pt_working_set: Pointer;
                      m_memory_type: String;

                      Constructor create_memory_mapped_file(p_name: String);
                      function f_display_memory_mapped_file: String;
                      function f_c_self: c_memory_mapped_file;
                      Destructor Destroy; Override;
                    end; // c_memory_mapped_file

         c_process= // one "process"
                    Class(c_basic_object)
                      // -- m_name: process_name from process handle
                      m_main_module_name: String;
                      m_process_path: String;

                      m_process_id: Integer;
                      m_process_priority: String;
                      m_module_count: Integer;

                      m_kernel_time: String;
                      m_user_time: String;
                      m_cpu_time: String;

                      m_c_module_list: tStringList;
                      m_module_handle_array: array of Integer;

                      m_c_memory_mapped_file_list: tStringList;

                      Constructor create_process(p_name: String);

                      function f_display_process: String;

                      function f_module_count: Integer;
                      function f_c_self: c_process;
                      function f_c_module(p_module_index: Integer): c_module;
                      function f_index_of(p_module_name: String): Integer;
                      function f_c_find_by_module(p_module_name: String): c_module;
                      procedure add_module(p_module_name: String; p_c_element: c_module);
                      function f_c_add_module(p_module_name: String): c_module;
                      procedure display_module_list;

                      function f_memory_mapped_file_count: Integer;
                      function f_c_memory_mapped_file(p_memory_mapped_file_index: Integer): c_memory_mapped_file;
                      function f_index_of_memory_mapped_file(p_memory_mapped_file_name: String): Integer;
                      function f_c_find_by_memory_mapped_file(p_memory_mapped_file_name: String): c_memory_mapped_file;
                      procedure add_memory_mapped_file(p_memory_mapped_file_name: String; p_c_memory_mapped_file: c_memory_mapped_file);
                      function f_c_add_memory_mapped_file(p_memory_mapped_file_name: String): c_memory_mapped_file;
                      procedure display_memory_mapped_file_list;

                      Destructor Destroy; Override;
                    end; // c_process

         c_process_list= // "process" list
                         Class(c_basic_object)
                           m_c_process_list: tStringList;

                           Constructor create_process_list(p_name: String);

                           function f_process_count: Integer;
                           function f_c_process(p_process_index: Integer): c_process;
                           function f_index_of(p_process_index: String): Integer;
                           function f_c_find_by_process(p_process_index: String): c_process;
                           procedure add_process(p_process_index: String; p_c_process: c_process);
                           function f_c_add_process(p_process_index: String): c_process;
                           procedure display_process_list;

                           procedure get_nt_process_list(p_do_build_memory_mapped_file_list: Boolean);

                           Destructor Destroy; Override;
                         end; // c_process_list

  implementation
    uses SysUtils, psApi, u_c_display, u_display_hex_2;

    // -- c_module

    Constructor c_module.create_module(p_name: String);
      begin
        Inherited create_basic_object(p_name);
      end; // create_module

    function c_module.f_c_self: c_module;
      begin
        Result:= Self;
      end; // f_c_self

    function c_module.f_display_module: String;
      begin
        Result:= Format('%-10s ', [m_name]);
      end; // f_display_module

    Destructor c_module.Destroy;
      begin
        InHerited;
      end; // Destroy

    // -- c_memory_mapped_file

    Constructor c_memory_mapped_file.create_memory_mapped_file(p_name: String);
      begin
        Inherited create_basic_object(p_name);
      end; // create_memory_mapped_file

    function c_memory_mapped_file.f_display_memory_mapped_file: String;
      begin
        Result:= Format('%-10s ', [m_name]);
      end; // f_display_memory_mapped_file

    function c_memory_mapped_file.f_c_self: c_memory_mapped_file;
      begin
        Result:= Self;
      end; // f_c_self

    Destructor c_memory_mapped_file.Destroy;
      begin
        InHerited;
      end; // Destroy

    // -- c_process

    Constructor c_process.create_process(p_name: String);
      begin
        Inherited create_basic_object(p_name);

        m_c_module_list:= tStringList.Create;
        m_c_memory_mapped_file_list:= tStringList.Create;
      end; // create_process

    function c_process.f_display_process: String;
      begin
        Result:= Format('%-10s ', [m_name]);
      end; // f_display_process

    function c_process.f_c_self: c_process;
      begin
        Result:= Self;
      end; // f_c_self
        
    function c_process.f_module_count: Integer;
      begin
        Result:= m_c_module_list.Count;
      end; // f_module_count

    function c_process.f_c_module(p_module_index: Integer): c_module;
      begin
        Result:= c_module(m_c_module_list.Objects[p_module_index]);
      end; //  f_c_module

    function c_process.f_index_of(p_module_name: String): Integer;
      begin
        Result:= m_c_module_list.IndexOf(p_module_name);
      end; // f_index_of

    function c_process.f_c_find_by_module(p_module_name: String): c_module;
      var l_index_of: Integer;
      begin
        l_index_of:= f_index_of(p_module_name);
        if l_index_of< 0
          then Result:= Nil
          else Result:= c_module(m_c_module_list.Objects[l_index_of]);
      end; // f_c_find_by_module

    procedure c_process.add_module(p_module_name: String; p_c_element: c_module);
      begin
        m_c_module_list.AddObject(p_module_name, p_c_element);
      end; // add_module

    function c_process.f_c_add_module(p_module_name: String): c_module;
      begin
        Result:= f_c_module(m_c_module_list.AddObject(p_module_name, c_module.create_module(p_module_name)));
      end; // f_c_add_module

    procedure c_process.display_module_list;
      var l_module_index: Integer;
      begin
        display(m_name+ ' '+ IntToStr(f_module_count));

        for l_module_index:= 0 to f_module_count- 1 do
          display(f_c_module(l_module_index).f_display_module);
      end; // display_module_list

    // --   memory mapped files

    function c_process.f_memory_mapped_file_count: Integer;
      begin
        Result:= m_c_memory_mapped_file_list.Count;
      end; // f_memory_mapped_file_count

    function c_process.f_c_memory_mapped_file(p_memory_mapped_file_index: Integer): c_memory_mapped_file;
      begin
        Result:= c_memory_mapped_file(m_c_memory_mapped_file_list.Objects[p_memory_mapped_file_index]);
      end; //  f_c_memory_mapped_file

    function c_process.f_index_of_memory_mapped_file(p_memory_mapped_file_name: String): Integer;
      begin
        Result:= m_c_memory_mapped_file_list.IndexOf(p_memory_mapped_file_name);
      end; // f_index_of

    function c_process.f_c_find_by_memory_mapped_file(p_memory_mapped_file_name: String): c_memory_mapped_file;
      var l_index_of: Integer;
      begin
        l_index_of:= f_index_of(p_memory_mapped_file_name);
        if l_index_of< 0
          then Result:= Nil
          else Result:= c_memory_mapped_file(m_c_memory_mapped_file_list.Objects[l_index_of]);
      end; // f_c_find_by_name

    procedure c_process.add_memory_mapped_file(p_memory_mapped_file_name: String; p_c_memory_mapped_file: c_memory_mapped_file);
      begin
        m_c_memory_mapped_file_list.AddObject(p_memory_mapped_file_name, p_c_memory_mapped_file);
      end; // add_memory_mapped_file

    function c_process.f_c_add_memory_mapped_file(p_memory_mapped_file_name: String): c_memory_mapped_file;
      begin
        Result:= c_memory_mapped_file.create_memory_mapped_file(p_memory_mapped_file_name);
        add_memory_mapped_file(p_memory_mapped_file_name, Result);
      end; // f_c_add_memory_mapped_file

    procedure c_process.display_memory_mapped_file_list;
      var l_memory_mapped_file_index: Integer;
      begin
        display(m_name+ ' '+ IntToStr(f_memory_mapped_file_count));

        for l_memory_mapped_file_index:= 0 to f_memory_mapped_file_count- 1 do
          display(f_c_memory_mapped_file(l_memory_mapped_file_index).f_display_memory_mapped_file);
      end; // display_memory_mapped_file_list

    Destructor c_process.Destroy;
      var l_module_index: Integer;
          l_memory_mapped_file_index: Integer;
      begin
        for l_module_index:= 0 to f_module_count- 1 do
          f_c_module(l_module_index).Free;
        m_c_module_list.Free;

        for l_memory_mapped_file_index:= 0 to f_memory_mapped_file_count- 1 do
          f_c_memory_mapped_file(l_memory_mapped_file_index).Free;
        m_c_memory_mapped_file_list.Free;

        InHerited;
      end; // Destroy

    // -- c_process_list

    Constructor c_process_list.create_process_list(p_name: String);
      begin
        Inherited create_basic_object(p_name);

        m_c_process_list:= tStringList.Create;
      end; // create_process_line

    function c_process_list.f_process_count: Integer;
      begin
        Result:= m_c_process_list.Count;
      end; // f_process_count

    function c_process_list.f_c_process(p_process_index: Integer): c_process;
      begin
        Result:= c_process(m_c_process_list.Objects[p_process_index]);
      end; //  f_c_process

    function c_process_list.f_index_of(p_process_index: String): Integer;
      begin
        Result:= m_c_process_list.IndexOf(p_process_index);
      end; // f_index_of

    function c_process_list.f_c_find_by_process(p_process_index: String): c_process;
      var l_index_of: Integer;
      begin
        l_index_of:= f_index_of(p_process_index);
        if l_index_of< 0
          then Result:= Nil
          else Result:= c_process(m_c_process_list.Objects[l_index_of]);
      end; // f_c_find_by_name

    procedure c_process_list.add_process(p_process_index: String; p_c_process: c_process);
      begin
        m_c_process_list.AddObject(p_process_index, p_c_process);
      end; // add_process

    function c_process_list.f_c_add_process(p_process_index: String): c_process;
      begin
        Result:= f_c_process(m_c_process_list.AddObject(p_process_index, c_process.create_process(p_process_index)));
      end; // f_c_add_process

    procedure c_process_list.display_process_list;
      var l_process_index: Integer;
      begin
        display(m_name+ ' '+ IntToStr(f_process_count));

        for l_process_index:= 0 to f_process_count- 1 do
          display(f_c_process(l_process_index).f_display_process);
      end; // display_process_list

    procedure c_process_list.get_nt_process_list(p_do_build_memory_mapped_file_list: Boolean);

      procedure build_process_list;

        procedure fill_process_times(p_process_handle: tHandle; p_c_process: c_process);
          var l_creation_file_time, l_exit_file_time, l_kernel_file_time, l_user_file_time: TFileTime;
              l_system_time: TSystemTime;
              l_kernel_day, l_user_day: integer;
              l_kernel_datetime, l_user_datetime: TDateTime;
              l_hours_string: string;

              // -- not used
              l_full_time: String;
          begin
            with p_c_process do
            begin
              GetProcessTimes(p_process_handle, l_creation_file_time,
                  l_exit_file_time, l_kernel_file_time, l_user_file_time);

              // -- kernel time
              FileTimeToSystemTime(l_kernel_file_time, l_system_time);
              l_kernel_datetime:= SystemTimeToDateTime(l_system_time);
              m_kernel_time:= TimeToStr(l_kernel_datetime);

              l_kernel_day:= l_system_time.wDay;
              l_hours_string:= Copy(m_kernel_time, 1, Pos(':', m_kernel_time)- 1);
              Delete(m_kernel_time, 1, Pos(':', m_kernel_time)- 1);

              l_full_time:=IntToStr(((l_kernel_day- 1)* 24)+ StrToInt(
                  l_hours_string))+ m_kernel_time;

              // -- user time
              FileTimeToSystemTime(l_user_file_time, l_system_time);
              l_user_datetime:= SystemTimeToDateTime(l_system_time);
              m_user_time:= TimeToStr(l_user_datetime);

              l_user_day:= l_system_time.wDay;
              l_hours_string:= Copy(m_user_time, 1, Pos(':', m_user_time)- 1);
              Delete(m_user_time, 1, Pos(':', m_user_time)- 1);

              l_full_time:=IntToStr(((l_user_day- 1)* 24)+ StrToInt(
                  l_hours_string))+ m_user_time;

              // -- cpu time
              m_cpu_time:= TimeToStr(l_user_datetime+ l_kernel_datetime);

              l_hours_string:= Copy(m_cpu_time, 1, Pos(':', m_cpu_time)- 1);
              Delete(m_cpu_time, 1, Pos(':', m_cpu_time)- 1);

              l_full_time:=IntToStr(((l_user_day- l_kernel_day)* 24)+ StrToInt(
                  l_hours_string))+ m_cpu_time;
            end; // with p_c_process
          end; // fill_process_times

        procedure build_module_list(p_process_handle: tHandle; p_c_process: c_process);
          var l_module_count_x_4: DWORD;
              l_module_name: array[0..MAX_PATH- 1] of char;

              l_module_index: Integer;
              l_c_module: c_module;
              l_module_info: TModuleInfo;
          begin
            with p_c_process do
            begin
              SetLength(m_module_handle_array, m_module_count);
              EnumProcessModules(p_process_handle, @m_module_handle_array[0], 4* m_module_count, l_module_count_x_4);

              for l_module_index:= 0 to m_module_count- 1 do
              begin
                GetModuleFileNameExA(p_process_handle, m_module_handle_array[l_module_index],l_module_name, SizeOf(l_module_name));

                l_c_module:= f_c_add_module(ExtractFileName(l_module_name));

                with l_c_module do
                begin
                  m_module_name:= m_name;
                  m_module_path:= ExtractFilePath(l_module_name);

                  if GetModuleInformation(p_process_handle, m_module_handle_array[l_module_index],
                      @l_module_info, SizeOf(l_module_info))
                    then
                      with l_module_info do
                      begin
                        m_pt_base_address:= lpBaseOfDll;
                        m_image_size:= SizeOfImage;
                        m_pt_entry_point:= EntryPoint;
                      end; // with l_module_info
                end; // with l_c_module
              end; // for l_module_index
            end; //  with p_c_process
          end; // build_module_list

        procedure build_memory_mapped_file_list(p_process_handle: tHandle; p_c_process: c_process);
          // -- the memory mapped files

          function f_memory_type(p_memory_type: DWORD): string;
            const k_memory_type_mask = DWORD($0000000F);
            begin
              Result := '';
              case p_memory_type and k_memory_type_mask of
                1: Result := 'Read-only';
                2: Result := 'Executable';
                4: Result := 'Read/write';
                5: Result := 'Copy on write';
                else
                  Result := 'Unknown';
              end; // case

              if p_memory_type and $100 <> 0
                then Result := Result + ', Shareable';
            end; // f_memory_type

          function f_get_file_name(p_mapped_file_name: String): String;
            var l_index: Integer;
            begin
              Result:= '';
              l_index:= Length(p_mapped_file_name);
              while (l_index>= 1) and (p_mapped_file_name[l_index]<> '\') do
              begin
                Result:= p_mapped_file_name[l_index]+ Result;
                Dec(l_index);
              end;
            end; // f_get_file_name

          const k_mapped_file_addresss_mask = DWORD($FFFFF000);
          var l_working_set_array: array[0..$3FFF - 1] of DWORD;
              l_mapped_file_index: Integer;
              l_mapped_file_name: array[0..MAX_PATH] of char;
              l_pt_working_set: Pointer;

              l_c_memory_mapped_file: c_memory_mapped_file;
              l_file_name: String;

          begin // build_memory_mapped_file_list
            with p_c_process do
              if QueryWorkingSet(p_process_handle, @l_working_set_array, SizeOf(l_working_set_array))
                then
                  for l_mapped_file_index := 1 to l_working_set_array[0] do
                  begin
                    l_pt_working_set := Pointer(l_working_set_array[l_mapped_file_index] and k_mapped_file_addresss_mask);

                    GetMappedFileName(p_process_handle, l_pt_working_set, l_mapped_file_name, SizeOf(l_mapped_file_name));
                    l_file_name:= f_get_file_name(l_mapped_file_name);

                    l_c_memory_mapped_file:= f_c_add_memory_mapped_file(l_file_name);
                    with l_c_memory_mapped_file do
                    begin
                      m_pt_working_set:= l_pt_working_set;
                      m_memory_type:= f_memory_type(l_working_set_array[l_mapped_file_index]);
                    end; // with l_c_memory_mapped_file
                  end; // with p_c_process, QueryWorkinSeg, for l_mapped_file_index
          end; // build_memory_mapped_file_list

        const k_process_id_array_max= 1000;
        var l_process_index: Integer;
            // -- 4x process count
            l_process_id_array_size: DWORD;
            l_process_id_array: array[0..1000] of Integer;
            l_process_name: array[0..MAX_PATH- 1] of char;
            l_process_handle: THandle;

            l_module_handle: HMODULE;
            l_module_count_x_4: DWORD;
            l_module_name: array[0..MAX_PATH- 1] of char;

            l_c_process: c_process;
            l_priority: String;

        begin // build_process_list
          if not EnumProcesses(@l_process_id_array, k_process_id_array_max* 4, l_process_id_array_size)
            then raise Exception.Create('PSAPI.DLL_not_found');

          display('Process Count: '+ IntToStr(l_process_id_array_size));

          for l_process_index:= 0 to (l_process_id_array_size div SizeOf(Integer)- 1) do
          begin
            l_process_handle:= OpenProcess(PROCESS_QUERY_INFORMATION or PROCESS_VM_READ, FALSE,
                l_process_id_array[l_process_index]);

            if l_process_handle<> 0
              then begin
                  if GetModuleFileNameExA(l_process_handle, 0, l_process_name, SizeOf(l_process_name))> 0
                    then begin
                        l_c_process:= f_c_add_process(ExtractFileName(l_process_name));

                        // -- get the first module, (2nd parameter: only 1 handle), which is the process itself
                        // --   as well as the module count
                        if EnumProcessModules(l_process_handle, @l_module_handle, SizeOf(l_module_handle), l_module_count_x_4)
                          then begin
                              display(Format('Process: %4d, Modules: %4d ', [l_process_index, l_module_count_x_4 div 4]));

                              with l_c_process do
                              begin
                                GetModuleFileNameExA(l_process_handle, l_module_handle, l_module_name, SizeOf(l_module_name));

                                m_main_module_name:= ExtractFileName(l_process_name);
                                m_process_id:= l_process_id_array[l_process_index];

                                fill_process_times(l_process_handle, l_c_process);

                                case GetPriorityClass(l_process_handle) of
                                  HIGH_PRIORITY_CLASS: l_priority:= 'High';
                                  IDLE_PRIORITY_CLASS: l_priority:= 'Idle';
                                  NORMAL_PRIORITY_CLASS: l_priority:= 'Normal';
                                  REALTIME_PRIORITY_CLASS: l_priority:= 'RealTime';
                                end;

                                m_process_priority:= l_priority;
                                m_process_path:= ExtractFilePath(l_process_name);

                                m_module_count:= l_module_count_x_4 div 4;

                                if m_module_count> 0
                                  then build_module_list(l_process_handle, l_c_process);

                                if p_do_build_memory_mapped_file_list
                                  then build_memory_mapped_file_list(l_process_handle, l_c_process);
                              end; // with l_c_process
                            end; // could enumerate the first module
                      end; // has found the process

                  CloseHandle(l_process_handle);
                end; // process_handle> 0
          end; // for l_process_index
        end; // build_process_list

      begin // get_nt_process_list
        build_process_list;
      end; // get_nt_process_list

    Destructor c_process_list.Destroy;
      var l_process_index: Integer;
      begin
        for l_process_index:= 0 to f_process_count- 1 do
          f_c_process(l_process_index).Free;
        m_c_process_list.Free;

        Inherited;
      end; // Destroy

    begin // u_c_process_list
    end. // u_c_process_list

