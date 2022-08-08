library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

entity pong is
  port (
    clk_7_159 : in std_logic;

    p1_up : in std_logic;
    p1_down : in std_logic;
    p2_up : in std_logic;
    p2_down : in std_logic;

    video_de : out std_logic;
    -- TODO: Remove
    video_vs : out std_logic;
    video_hs : out std_logic;
    video_rgb : out unsigned (23 downto 0)
  );
end entity;

architecture rtl of pong is
  signal h_sync : std_logic;
  signal h_blank : std_logic;

  signal v_sync : std_logic;
  signal v_blank : std_logic;

  signal h_count : unsigned (8 downto 0);
  signal v_count : unsigned (8 downto 0);

  signal input_count : unsigned (12 downto 0) := 13d"0";
  signal paddle_pos_1 : unsigned (7 downto 0) := 8d"128";
  signal paddle_pos_2 : unsigned (7 downto 0) := 8d"128";
  signal pad_1 : std_logic;
  signal pad_2 : std_logic;

  signal mono_video_out : unsigned (7 downto 0);
begin
  VIDEO_GEN : entity work.video port map (
    clk_7_159 => clk_7_159,

    pad_1 => pad_1,
    pad_2 => pad_2,

    h_sync => h_sync,
    h_blank => h_blank,
    h_count => h_count,
    v_sync => v_sync,
    v_blank => v_blank,
    v_count => v_count,

    mono_video_out => mono_video_out
    );

  PAD1 : entity work.paddle port map (
    paddle_pos => paddle_pos_1,

    h_sync => h_sync,

    v256 => v_count(8),
    h256 => h_count(8),
    h128 => h_count(7),
    h4 => h_count(2),

    pad => pad_1
    );

  PAD2 : entity work.paddle port map (
    paddle_pos => paddle_pos_2,

    h_sync => h_sync,

    v256 => v_count(8),
    -- Only difference from pad1
    h256 => not h_count(8),
    h128 => h_count(7),
    h4 => h_count(2),

    pad => pad_2
    );

  video_de <= (not h_blank) and (not v_blank);
  video_vs <= v_sync;
  video_hs <= h_sync;
  video_rgb <= mono_video_out & mono_video_out & mono_video_out;

  process (clk_7_159)
  begin
    if rising_edge(clk_7_159) then
      if input_count = 0 then
        input_count <= '1' & 12x"AAA";

        if p1_up = '1' then
          if paddle_pos_1 > 1 then
            paddle_pos_1 <= paddle_pos_1 - 1;
          end if;
        elsif p1_down = '1' then
          if paddle_pos_1 < 255 then
            paddle_pos_1 <= paddle_pos_1 + 1;
          end if;
        end if;

        if p2_up = '1' then
          if paddle_pos_2 > 1 then
            paddle_pos_2 <= paddle_pos_2 - 1;
          end if;
        elsif p2_down = '1' then
          if paddle_pos_2 < 255 then
            paddle_pos_2 <= paddle_pos_2 + 1;
          end if;
        end if;
      end if;

      input_count <= input_count - 1;
    end if;
  end process;
end architecture;