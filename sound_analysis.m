function varargout = sound_analysis(varargin)
% SOUND_ANALYSIS MATLAB code for sound_analysis.fig
%      SOUND_ANALYSIS, by itself, creates a new SOUND_ANALYSIS or raises the existing
%      singleton*.
%
%      H = SOUND_ANALYSIS returns the handle to a new SOUND_ANALYSIS or the handle to
%      the existing singleton*.
%
%      SOUND_ANALYSIS('CALLBACK',hObject,eventData,handles,...) calls the local
%      function named CALLBACK in SOUND_ANALYSIS.M with the given input arguments.
%
%      SOUND_ANALYSIS('Property','Value',...) creates a new SOUND_ANALYSIS or raises the
%      existing singleton*.  Starting from the left, property value pairs are
%      applied to the GUI before sound_analysis_OpeningFcn gets called.  An
%      unrecognized property name or invalid value makes property application
%      stop.  All inputs are passed to sound_analysis_OpeningFcn via varargin.
%
%      *See GUI Options on GUIDE's Tools menu.  Choose "GUI allows only one
%      instance to run (singleton)".
%
% See also: GUIDE, GUIDATA, GUIHANDLES

% Edit the above text to modify the response to help sound_analysis

% Last Modified by GUIDE v2.5 14-Oct-2021 18:32:45

% Begin initialization code - DO NOT EDIT
gui_Singleton = 1;
gui_State = struct('gui_Name',       mfilename, ...
                   'gui_Singleton',  gui_Singleton, ...
                   'gui_OpeningFcn', @sound_analysis_OpeningFcn, ...
                   'gui_OutputFcn',  @sound_analysis_OutputFcn, ...
                   'gui_LayoutFcn',  [] , ...
                   'gui_Callback',   []);
if nargin && ischar(varargin{1})
    gui_State.gui_Callback = str2func(varargin{1});
end

if nargout
    [varargout{1:nargout}] = gui_mainfcn(gui_State, varargin{:});
else
    gui_mainfcn(gui_State, varargin{:});
end
% End initialization code - DO NOT EDIT


% --- Executes just before sound_analysis is made visible.
function sound_analysis_OpeningFcn(hObject, eventdata, handles, varargin)
% This function has no output args, see OutputFcn.
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% varargin   command line arguments to sound_analysis (see VARARGIN)

global flag1;flag1=0;
global flag2;flag2=0;
global sounding_flag;sounding_flag=0;
global listbox_string;
global myplayer;
global sound_data;
global ori_Fs;
% global sound_data;

wavlist = folder_search(pwd,'wav');
file_length = length(wavlist);
listbox_string = '';
fix_string = '';
for i = 1:1:file_length
    listbox_string = [listbox_string, wavlist{i}, newline];
    temp = strsplit(wavlist{i},'\');
    fix_string = [fix_string, temp(end)];
end
% disp(listbox_string);
set(handles.listbox1,'string',fix_string); 

% Choose default command line output for sound_analysis
handles.output = hObject;

% Update handles structure
guidata(hObject, handles);

% UIWAIT makes sound_analysis wait for user response (see UIRESUME)
% uiwait(handles.figure1);


% --- Outputs from this function are returned to the command line.
function varargout = sound_analysis_OutputFcn(hObject, eventdata, handles) 
% varargout  cell array for returning output args (see VARARGOUT);
% hObject    handle to figure
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Get default command line output from handles structure
varargout{1} = handles.output;




% --- Executes on button press in pushbutton1.
function pushbutton1_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global flag1;
global myrecorder;

Fs=96000;
Bits=16;
Ch=2;
if flag1 == 0
    myrecorder=audiorecorder(Fs,Bits,Ch);
    record(myrecorder);
    flag1 = 1;
    set(handles.pushbutton1,'string','Finish');
else
    stop(myrecorder);
    fulldata = getaudiodata(myrecorder);
    
    data=fulldata(:,1);                 %取单声道  
    n=0:length(data)-1;                 %信号等长序列
    time=n/Fs;                          %时间轴对齐
    axes(handles.axes1);
    plot(time,data);

    title('音频信号时域图')  
    xlabel('time/s');       
    ylabel('amplitude');      
    grid on;      

    N=length(data);                     %取信号长度
    result=fft(data,N);                 %N点FFT变换
    P=abs(result);                      %取模
    frequence=n*Fs/N;                   %建立频率轴
    axes(handles.axes2);
    plot(frequence(1:fix(N/2)),P(1:fix(N/2)));
    axis([0,4000,-inf,inf]);
    title('音频信号频谱图');
    xlabel('frequence/Hz');      
    ylabel('amplitude');        
    grid on;                
    
    [~,index]=max(data);              %找声音峰值
    timewin=floor(0.015*Fs);          %提取峰值前后0.015s
    xwin=data(index-timewin:index+timewin);
    [y,~]=xcov(xwin);
    ylen=length(y);
    axes(handles.axes3);
    plot(y);
    fall_step=50;
    halflen=(ylen+1)/2 +fall_step;
    yy=y(halflen: ylen);
    [~,maxindex] = max(yy);
    fmax=Fs/(maxindex+30);
    full_str=num2str(fmax);
    cut_str=strsplit(full_str,'.');
    text=[cut_str{1},'Hz; '];
    if fmax<210
        text=[text,'Male'];
    else
        text=[text,'Female'];
    end
    set(handles.text7,'string',text); 

    t = datestr(now);
    fix_t = strrep(t(13:end),':','_');
    name = ['myrecord_',fix_t,'.wav'];
    audiowrite(name,data,Fs);
    set(handles.edit2,'string',name);
    
    wavlist = folder_search(pwd,'wav');
    file_length = length(wavlist);
    listbox_string = '';
    fix_string = '';
    for i = 1:1:file_length
        listbox_string = [listbox_string, wavlist{i}, newline];
        temp = strsplit(wavlist{i},'\');
        fix_string = [fix_string, temp(end)];
        if strcmp(temp(end),name)
            set(handles.listbox1,'value',i);
        end
    end

    set(handles.listbox1,'string',fix_string); 
    set(handles.pushbutton1,'string','Record');
    set(handles.popupmenu2,'value',1);
    flag1 = 0;
end


% --- Executes on button press in pushbutton2.
function pushbutton2_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global flag2;
global myplayer;
global sound_data;
global ori_Fs;

upend_value=get(handles.radiobutton1,'value');

if flag2 == 0
    filename=get(handles.edit2,'string');
    [sound_data,Fs]=audioread(filename);
    if upend_value
        sound_data = flip(sound_data);
    end
    ori_Fs=Fs;
    % vocaltime=length(sound_data)/Fs;
    slider_x=get(handles.slider3,'value');
    speed=(slider_x+0.5).*(slider_x<0.5)+(2*slider_x).*(slider_x>=0.5);
    fix_frequence=Fs*speed;
    myplayer=audioplayer(sound_data,fix_frequence,16);
    set(handles.pushbutton2,'string','Stop');
    flag2 = 1;
    play(myplayer);
 
else
    stop(myplayer);
    set(handles.pushbutton2,'string','Play');
    flag2 = 0;
end

% function play_over_back(hObject, eventdata, handles)
% global myplayer;
% global flag2;
% 
% while (isplaying(myplayer))
%     
% end
% 
% stop(myplayer);
% set(handles.pushbutton2,'string','Play');
% flag2 = 0;

function edit1_Callback(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit1 as text
%        str2double(get(hObject,'String')) returns contents of edit1 as a double


% --- Executes during object creation, after setting all properties.
function edit1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on slider movement.
function slider1_Callback(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global myplayer;

process = get(handles.slider1,'Value');
aim_start = round(process*myplayer.TotalSamples);
try        %用try结构是怕在player暂未生成时用户移动滑动条而报错
    pause(myplayer);
    play(myplayer,aim_start);
%     set(handles.togglebutton1,'String','l l','FontSize',15,'Value',1);
catch
    set(handles.slider1,'Value',0);
end

% --- Executes during object creation, after setting all properties.
function slider1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on button press in pushbutton3.
function pushbutton3_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton4.
function pushbutton4_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on slider movement.
function slider2_Callback(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global myplayer;
global sound_data;
global ori_Fs;

state_value = get(handles.slider3,'Value');
speed = (state_value+0.5).*(state_value<0.5) + (2*state_value).*(state_value>=0.5);
vocal_value = get(handles.slider2,'Value');
amp = (2*vocal_value).*(vocal_value<=0.5) + (6*vocal_value-2).*(vocal_value>0.5);
try       
    aim_start = myplayer.CurrentSample;
    fix_sound_data=amp*sound_data;
    fix_frequence=speed*ori_Fs;
    if isplaying(myplayer)
        pause(myplayer);
        myplayer=audioplayer(fix_sound_data,fix_frequence,16);
        play(myplayer,aim_start);
    else
        myplayer=audioplayer(fix_sound_data,fix_frequence,16);
    end
catch
end


% --- Executes during object creation, after setting all properties.
function slider2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end


% --- Executes on selection change in listbox1.
function listbox1_Callback(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns listbox1 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from listbox1
% sel=get(gcf,'selectiontype');
items = get(hObject,'String');
index_selected = get(hObject,'Value');
item_selected = items{index_selected};
set(handles.edit2,'string',item_selected); 
% display([pwd,'\',item_selected]);





% --- Executes during object creation, after setting all properties.
function listbox1_CreateFcn(hObject, eventdata, handles)
% hObject    handle to listbox1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: listbox controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton6.
function pushbutton6_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton6 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
filename=get(handles.edit2,'string');
[vocal_data,Fs]=audioread(filename);
[~,index]=max(vocal_data);              %找声音峰值
vocal_time=floor(0.015*Fs);                %提取峰值前后0.015s
x=vocal_data(index-vocal_time:index+vocal_time);
[y,~]=xcov(x);
axes(handles.axes3);
plot(y);
% [~,y_index] = max(y);
% set(handles.edit5,'string',num2str(y_index));
y_len=length(y);
fall_step=50;
halflen=(y_len+1)/2 +fall_step;
y_half=y(halflen: y_len);
[~,maxindex] = max(y_half);
fmax=Fs/(maxindex+fall_step);
full_str=num2str(fmax);
cut_str=strsplit(full_str,'.');
text=[cut_str{1},'Hz; '];
% disp(['基音频率为 ', num2str(fmax), ' Hz'])
if fmax<210
    text=[text,'Male'];
else
    text=[text,'Female'];
end
set(handles.text7,'string',text);

n=0:length(vocal_data)-1;           %信号等长序列
time=n/Fs;                          %时间轴对齐
axes(handles.axes1);
plot(time,vocal_data);
title('音频信号时域图')  
xlabel('time/s');       
ylabel('amplitude');      
grid on;      

N=length(vocal_data);               %取信号长度
result=fft(vocal_data,N);           %N点FFT变换
P=abs(result);                      %取模
frequence=n*Fs/N;                   %建立频率轴
axes(handles.axes2);
plot(frequence(1:fix(N/2)),P(1:fix(N/2)));
axis([0,4000,-inf,inf]);
title('音频信号频谱图');
xlabel('frequence/Hz');      
ylabel('amplitude');        
grid on;   


% --- Executes on slider movement.
function slider3_Callback(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
% Hints: get(hObject,'Value') returns position of slider
%        get(hObject,'Min') and get(hObject,'Max') to determine range of slider
global myplayer;
global sound_data;
global ori_Fs;

state_value = get(handles.slider3,'Value');
speed = (state_value+0.5).*(state_value<0.5) + (2*state_value).*(state_value>=0.5);
vocal_value = get(handles.slider2,'Value');
amp = (2*vocal_value).*(vocal_value<=0.5) + (6*vocal_value-2).*(vocal_value>0.5);
try       
    aim_start = myplayer.CurrentSample;
    fix_frequence=speed*ori_Fs;
    fix_sound_data=amp*sound_data;
    if isplaying(myplayer)
        pause(myplayer);
        myplayer=audioplayer(fix_sound_data,fix_frequence,16);
        play(myplayer,aim_start);
    else
        myplayer=audioplayer(fix_sound_data,fix_frequence,16);
    end
catch
end


% --- Executes during object creation, after setting all properties.
function slider3_CreateFcn(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: slider controls usually have a light gray background.
if isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor',[.9 .9 .9]);
end



function edit2_Callback(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit2 as text
%        str2double(get(hObject,'String')) returns contents of edit2 as a double


% --- Executes during object creation, after setting all properties.
function edit2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton8.
function pushbutton8_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton8 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)


% --- Executes on button press in pushbutton9.
function pushbutton9_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton9 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
global listbox_string;
filename=get(handles.edit2,'string');
delete(filename);
set(handles.listbox1,'value',1);

items = get(handles.popupmenu2,'string');
index_selected = get(handles.popupmenu2,'value');
filetype = items{index_selected};

filelist = folder_search(pwd,filetype);
file_length = length(filelist);
listbox_string = '';
fix_string = '';
for i = 1:1:file_length
    listbox_string = [listbox_string, filelist{i}, newline];
    temp = strsplit(filelist{i},'\');
    fix_string = [fix_string, temp(end)];
end
set(handles.listbox1,'string',fix_string); 
set(handles.edit2,'string',''); 


% --- Executes on button press in pushbutton10.
function pushbutton10_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton10 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
wavlist = folder_search(pwd,'wav');
file_length = length(wavlist);
for i = 1:1:file_length
    delete(wavlist{i});
end
set(handles.listbox1,'string',''); 
set(handles.edit2,'string',''); 


% --- Executes on selection change in popupmenu2.
function popupmenu2_Callback(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: contents = cellstr(get(hObject,'String')) returns popupmenu2 contents as cell array
%        contents{get(hObject,'Value')} returns selected item from popupmenu2
global listbox_string;

items = get(handles.popupmenu2,'String');
index_selected = get(handles.popupmenu2,'Value');
item_selected = items{index_selected};
set(handles.listbox1,'value',1);

item_list = folder_search(pwd,item_selected);
file_length = length(item_list);
listbox_string = '';
fix_string = '';
for i = 1:1:file_length
    listbox_string = [listbox_string, item_list{i}, newline];
    temp = strsplit(item_list{i},'\');
    fix_string = [fix_string, temp(end)];
end
set(handles.listbox1,'string',fix_string); 
% set(handles.edit2,'string',''); 



% --- Executes during object creation, after setting all properties.
function popupmenu2_CreateFcn(hObject, eventdata, handles)
% hObject    handle to popupmenu2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: popupmenu controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over slider3.
function slider3_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to slider3 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.slider3,'value',0.5);

global myplayer;
global sound_data;
global ori_Fs;

try       
    aim_start = myplayer.CurrentSample;
    fix_frequence=ori_Fs;
    if isplaying(myplayer)
        pause(myplayer);
        myplayer=audioplayer(sound_data,fix_frequence,16);
        play(myplayer,aim_start);
    else
        myplayer=audioplayer(sound_data,fix_frequence,16);
    end
catch
    
end




% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over slider2.
function slider2_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to slider2 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.slider2,'value',0.5);
global myplayer;
global sound_data;
global ori_Fs;

state_value = get(handles.slider3,'Value');
speed = (state_value+0.5).*(state_value<0.5) + (2*state_value).*(state_value>=0.5);
vocal_value = get(handles.slider2,'Value');
amp = (2*vocal_value).*(vocal_value<=0.5) + (6*vocal_value-2).*(vocal_value>0.5);

try       
    aim_start = myplayer.CurrentSample;
    fix_sound_data=amp*sound_data;
    fix_frequence=speed*ori_Fs;
    if isplaying(myplayer)
        pause(myplayer);
        myplayer=audioplayer(fix_sound_data,fix_frequence,16);
        play(myplayer,aim_start);
    else
        myplayer=audioplayer(fix_sound_data,fix_frequence,16);
    end
catch
    
end


% --- If Enable == 'on', executes on mouse press in 5 pixel border.
% --- Otherwise, executes on mouse press in 5 pixel border or over slider1.
function slider1_ButtonDownFcn(hObject, eventdata, handles)
% hObject    handle to slider1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
set(handles.slider1,'value',0);
global myplayer
try
    pause(myplayer);
    play(myplayer);
catch
    set(handles.slider1,'Value',0);
end


% --- Executes on button press in radiobutton1.
function radiobutton1_Callback(hObject, eventdata, handles)
% hObject    handle to radiobutton1 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hint: get(hObject,'Value') returns toggle state of radiobutton1



function edit4_Callback(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit4 as text
%        str2double(get(hObject,'String')) returns contents of edit4 as a double


% --- Executes during object creation, after setting all properties.
function edit4_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit4 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end



function edit5_Callback(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)

% Hints: get(hObject,'String') returns contents of edit5 as text
%        str2double(get(hObject,'String')) returns contents of edit5 as a double


% --- Executes during object creation, after setting all properties.
function edit5_CreateFcn(hObject, eventdata, handles)
% hObject    handle to edit5 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    empty - handles not created until after all CreateFcns called

% Hint: edit controls usually have a white background on Windows.
%       See ISPC and COMPUTER.
if ispc && isequal(get(hObject,'BackgroundColor'), get(0,'defaultUicontrolBackgroundColor'))
    set(hObject,'BackgroundColor','white');
end


% --- Executes on button press in pushbutton12.
function pushbutton12_Callback(hObject, eventdata, handles)
% hObject    handle to pushbutton12 (see GCBO)
% eventdata  reserved - to be defined in a future version of MATLAB
% handles    structure with handles and user data (see GUIDATA)
aim_Fs=16000;
try
filename=get(handles.edit2,'string');
[sound_data,ori_Fs]=audioread(filename);
[P,Q] = rat(aim_Fs/ori_Fs);
resample_data=resample(sound_data,P,Q);                 %重采样
audiowrite('word_analysis.wav',resample_data,aim_Fs);

file_data = fopen('word_analysis.wav','rb');
byte_data = fread(file_data);
fclose(file_data);
delete('word_analysis.wav');

datalength=size(byte_data,1);
encoder = org.apache.commons.codec.binary.Base64;
json_data = char(encoder.encode(byte_data));

api_key = 'Fn40opF9VwBxyuWCm652gQQO';
secret_key = '8GivRan69sYnQuwHZCDiZwrxKZTKtg2j';


url_token = ['https://openapi.baidu.com/oauth/2.0/token?grant_type=client_credentials&client_id=',api_key,'&client_secret=',secret_key];
token = webread(url_token);
token = token.access_token ;
url = 'http://vop.baidu.com/server_api';
data = struct('format','wav','token',token,'len',datalength,...
    'speech',json_data,'cuid','Sirius','rate',16000,'channel',1);
analysis = webwrite(url,data);
text = analysis.result{:};
set(handles.edit5,'string',text);
catch
end


















