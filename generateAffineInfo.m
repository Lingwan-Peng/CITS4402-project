% Adapts Rodrigues' rotation formula to generate transform matrix A
% @param rotation_axis : 1x3 rotation axis [x y z] (The rotaional axis starts from origin)
% @param rotation_angle : Rotation angle along the axis, in rad
% @param offset : 1x3 [x y z], offset
function A = generateAffineInfo(rotation_axis, rotation_angle, offset)
    rotation_axis = [rotation_axis 0];      % Increase one dimension
    N = zeros(4, 4);
    N(1, 2) = -rotation_axis(3);
    N(1, 3) = rotation_axis(2);
    N(2, 1) = rotation_axis(3);
    N(2, 3) = -rotation_axis(1);
    N(3, 1) = -rotation_axis(2);
    N(3, 2) = rotation_axis(1);

    A = eye(4);
    A = A.*cos(rotation_angle);
    A = A + (rotation_axis' * rotation_axis) .* (1 - cos(rotation_angle));
    A = A + sin(rotation_angle) .* N;

    A(1:3, 4) = A(1:3, 4) + offset';
    A(4, 4) = 1;
end