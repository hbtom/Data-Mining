clc;
clear;
close all;
% item_tag = load('user_taggedartists-timestamps.dat');
% user_user = load('user_friends.dat');
% user_item = load('user_artists.dat');
% save('raw_data.mat','item_tag','user_user','user_item');
load('raw_data.mat');
item_tag = item_tag(1:end,[2,3]);
[item_C,item_ia,item_ic] = unique(item_tag(1:end,1));
[tag_C,tag_ia,tag_ic] = unique(item_tag(1:end,2));
% [item]




