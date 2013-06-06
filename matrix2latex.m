function matrix2latex(matrix, varargin)

% function: matrix2latex(...)
%
% Usage:
% matrix2late(matrix, varargs)
% where
%   - matrix is a 2 dimensional numerical or cell array
%   - varargs is one ore more of the following (denominator, value) combinations
%      + filename is a valid filename, in which the resulting latex code will
%      be stored. If not provided 'stdin' is used
%      + 'rowLabels', array -> Can be used to label the rows of the
%      resulting latex table
%      + 'columnLabels', array -> Can be used to label the columns of the
%      resulting latex table
%      + 'alignment', 'value' -> Can be used to specify the alginment of
%      the table within the latex document. Valid arguments are: 'l', 'c',
%      and 'r' for left, center, and right, respectively
%      + 'format', 'value' -> Can be used to format the input data. 'value'
%      has to be a valid format string, similar to the ones used in
%      fprintf('format', value);
%      + 'size', 'value' -> One of latex' recognized font-sizes, e.g. tiny,
%      HUGE, Large, large, LARGE, etc.
%
% Example input:
%   matrix = [1.5 1.764; 3.523 0.2];
%   rowLabels = {'row 1', 'row 2'};
%   columnLabels = {'col 1', 'col 2'};
%   matrix2latex(matrix, 'out.tex', 'rowLabels', rowLabels, 'columnLabels', columnLabels, 'alignment', 'c', 'format', '%-6.2f', 'size', 'tiny');
%
% The resulting latex file can be included into any latex document by:
% /input{out.tex}
%
% Enjoy life!!!

% Author:   M. Koehler
% Contact:  koehler@in.tum.de
% Version:  1.1
% Date:     May 09, 2004
% Modified by Gustavo Camps-Valls, Jan 2013
% Modified by JoRdI, Jun 2013
%
% This software is published under the GNU GPL, by the free software
% foundation. For further reading see: http://www.gnu.org/licenses/licenses.html#GPL

rowLabels = [];
colLabels = [];
alignment = 'l';
format = [];
textsize = [];
% if (rem(nargin,2) == 1 || nargin < 2)
%     error('matrix2latex:error', 'Incorrect number of arguments to %s.', mfilename);
% end

for j=1:2:(nargin-2)
    pname = varargin{j};
    pval = varargin{j+1};
    
    switch lower(pname)
        case 'filename'
            filename = pval;
        case 'rowlabels'
            rowLabels = pval;
            if isnumeric(rowLabels)
                rowLabels = cellstr(num2str(rowLabels(:)));
            end
        case 'columnlabels'
            colLabels = pval;
            if isnumeric(colLabels)
                colLabels = cellstr(num2str(colLabels(:)));
            end
        case 'alignment'
            alignment = lower(pval);
            switch alignment
                case {'right', 'left', 'center', 'r', 'l', 'c'}
                    alignment = alignment(1);
                otherwise
                    alignment = 'l';
                    warning('matrix2latex:error', 'Unkown alignment. (Set to \''left\''.)');
            end
        case 'format'
            format = lower(pval);
        case 'textsize'
            textsize = pval;
        otherwise
            error('matrix2latex:error', 'Unknown parameter name: %s.', pname);
    end
  
end

if ~exist('filename', 'var')
    fid = 1; % stdin
else
    fid = fopen(filename, 'a');
end

width = size(matrix, 2);
height = size(matrix, 1);

if isnumeric(matrix)
    matrix = num2cell(matrix);
    for h=1:height
        for w=1:width
            if(~isempty(format))
                matrix{h, w} = num2str(matrix{h, w}, format);
            else
                matrix{h, w} = num2str(matrix{h, w});
            end
        end
    end
end

fprintf(fid, '\\begin{table}[H]\n\\begin{center}\n\\caption{Results blablabla\\label{tab:}}\n\\setlength{\\tabcolsep}{4pt}\n');
if(~isempty(textsize))
    fprintf(fid, '\\begin{%s}\n', textsize);
end

fprintf(fid, '\\begin{tabular}{|');

if(~isempty(rowLabels))
    fprintf(fid, 'l|');
end
for i=1:width
    fprintf(fid, '%c|', alignment);
end
fprintf(fid, '}\n');
fprintf(fid, '\\hline\n');

if(~isempty(colLabels))
    if(~isempty(rowLabels))
        fprintf(fid, ' &');
    end
    for w=1:width-1
        fprintf(fid, ' \\textbf{%s} &', colLabels{w});
    end
    fprintf(fid, ' \\textbf{%s} \\\\ \\hline\n', colLabels{width});
end

for h=1:height
    if(~isempty(rowLabels))
        fprintf(fid, '\\textbf{%s}  &  ', rowLabels{h});
    end
    for w=1:width-1
        fprintf(fid, '%s  &  ', matrix{h, w});
    end
    fprintf(fid, '%s \\\\ \\hline\n', matrix{h, width});
end

fprintf(fid, '\\end{tabular}\n');

if(~isempty(textsize))
    fprintf(fid, '\\end{%s}\n', textsize);
end
fprintf(fid, '\\end{center}\n\\end{table}\n\n');

if fid > 2
    fclose(fid);
end
