function out=read_MITKPoints(filename)


global bounds;
global points;

bounds = zeros(6,1);
points = [];


out = [];
try
    tree = xmlread(filename);
catch
    error('Failed to read XML file %s.',filename);
end

% Recurse over child nodes. This could run into problems
% with very deeply nested trees.
try
    theStruct = parseChildNodes(tree);
catch
    error('Unable to parse XML file %s.',filename);
end

out.bounds = bounds;
out.points = points;

end

% ----- Local function PARSECHILDNODES -----
function children = parseChildNodes(theNode)
% Recurse over node children.
global bounds;
global points;
children = [];
if theNode.hasChildNodes
    childNodes = theNode.getChildNodes;
    numChildNodes = childNodes.getLength;
    allocCell = cell(1, numChildNodes);
    
    children = struct(             ...
        'Name', allocCell, 'Attributes', allocCell,    ...
        'Data', allocCell, 'Children', allocCell);
    
    for count = 1:numChildNodes
        theChild = childNodes.item(count-1);
        children(count) = makeStructFromNode(theChild);
        if strcmp( children(count).Name,'Bounds')
            for i=1:numel(children(count).Children)
                ch = children(count).Children(i);
                if strcmp( ch.Name,'Min')
                    bounds(1) = str2num(ch.Attributes(2).Value);
                    bounds(3) = str2num(ch.Attributes(3).Value);
                    bounds(5) = str2num(ch.Attributes(4).Value);
                elseif strcmp( ch.Name,'Max')
                    bounds(2) = str2num(ch.Attributes(2).Value);
                    bounds(4) = str2num(ch.Attributes(3).Value);
                    bounds(6) = str2num(ch.Attributes(4).Value);
                end
            end
        elseif strcmp( children(count).Name,'point')
            for i=1:numel(children(count).Children)
                ch = children(count).Children(i);
                if strcmp(ch.Name,'id')
                    chch = ch.Children;
                    id = str2num(chch.Data);
                    npts = numel(points);
                    points(npts+1).id = id;
                elseif strcmp( ch.Name,'specification')
                    chch = ch.Children;
                    npts = numel(points);
                    points(npts).tag = chch.Data;
                elseif strcmp( ch.Name,'x')
                    chch = ch.Children;
                    npts = numel(points);
                    points(npts).coordinates(1) = str2num(chch.Data);
                elseif strcmp( ch.Name,'y')
                    chch = ch.Children;
                    npts = numel(points);
                    points(npts).coordinates(2) = str2num(chch.Data);
                elseif strcmp( ch.Name,'z')
                    chch = ch.Children;
                    npts = numel(points);
                    points(npts).coordinates(3) = str2num(chch.Data);
                end
            end
        end
    end
end
end

% ----- Local function MAKESTRUCTFROMNODE -----
function nodeStruct = makeStructFromNode(theNode)
% Create structure of node info.

nodeStruct = struct(                        ...
    'Name', char(theNode.getNodeName),       ...
    'Attributes', parseAttributes(theNode),  ...
    'Data', '',                              ...
    'Children', parseChildNodes(theNode));

if any(strcmp(methods(theNode), 'getData'))
    nodeStruct.Data = char(theNode.getData);
else
    nodeStruct.Data = '';
end
end

% ----- Local function PARSEATTRIBUTES -----
function attributes = parseAttributes(theNode)
% Create attributes structure.

attributes = [];
if theNode.hasAttributes
    theAttributes = theNode.getAttributes;
    numAttributes = theAttributes.getLength;
    allocCell = cell(1, numAttributes);
    attributes = struct('Name', allocCell, 'Value', ...
        allocCell);
    
    for count = 1:numAttributes
        attrib = theAttributes.item(count-1);
        attributes(count).Name = char(attrib.getName);
        attributes(count).Value = char(attrib.getValue);
    end
end
end