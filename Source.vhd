----------------------------------------------------------------------------------
-- Company: University of Regina    
-- Engineer: Nickolas Schmidt
-- Create Date: 11/21/2017 02:16:58 PM
-- Design Name: Calender simulation
-- Module Name: Calendar - Behavioral
-- Project Name: Calednar simulation
----------------------------------------------------------------------------------
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
entity Calendar is
    Port ( CLK : in STD_LOGIC; --Used for the clock process 
           SSEG_CA : out STD_LOGIC_VECTOR (7 downto 0); --Used to display 0-9 on the 7 segment displays
           SSEG_AN : out STD_LOGIC_VECTOR (3 downto 0); --Used to control the active 7segment displays
           AN_OFF : out STD_LOGIC_VECTOR  (3 downto 0); --Used to shut off the innactive 7 segment displays
           Enable : in STD_LOGIC; --Used to turn on and off the display
           Leap : in STD_LOGIC; --Used for a leap year button
           Birthday : in STD_LOGIC); --Used for a birthday button
           
end Calendar;
--This calendar system outputs 4 digits on the 7 segment display
--The clock is slowed to use a multiplexar to rapidly blink 4 different 7 segment displays
architecture Behavioral of Calendar is

--Constants for Min/Max value. Used to reset the clock values
constant MINVAL :STD_LOGIC_VECTOR( 31 downto 0) := x"00000000"; --Used as a variable for the clock divider
constant MAXVAL :STD_LOGIC_VECTOR( 31 downto 0) := x"FFFFFFFF"; --Used to reset the CLK variable

--Signals used for simulating a calendar
Signal D0 : STD_LOGIC_VECTOR(3 downto 0); --First signal used for 10s digit in Calendar Month
Signal D1 : STD_LOGIC_VECTOR(3 downto 0); --Second signal used for ones digit in Calender Month
Signal D2 : STD_LOGIC_VECTOR(3 downto 0); -- Thrid signal used for 10s digit in Calendar days
Signal D3 : STD_LOGIC_VECTOR(3 downto 0); --Fourth signal used for Ones digit in Calendar Day
signal CNT : STD_LOGIC_VECTOR(9 downto 0); --Counter1
Signal CLKdiv : STD_LOGIC_VECTOR(16 downto 0); --Counter2
Signal Month : STD_LOGIC_VECTOR(3 downto 0); --Month Counter
Signal Selector : STD_LOGIC_VECTOR(3 downto 0); --Used to determine the D0,D1,D2,D3 values
Signal BCD: STD_LOGIC_VECTOR(3 downto 0);-- Used to show what value is showing on the 7 segmennt display


begin
process(CLK)
Variable SCNT: integer range 1 to 4; --Used to place zeroes in correct position
  begin
    if (Enable ='1') then
       if(CLK'event and CLK ='1') then
            CNT<= CNT +1; --Add one to fast clock
            if(CNT = MAXVAL(9 downto 0)) then --Counter 1 max
                CNT<= MINVAL(9 downto 0); --Set it back to 0
                CLKdiv <= CLKdiv +1; --Increment Counter 2
                if( SCNT =4) then
                    SCNT:=0;
                 end if;
                Selector<= "1111"; --Increment Selector
                Selector(SCNT) <= '0';
                SCNT:= SCNT +1;
                if(CLKdiv =MAXVAL(16 downto 0)) then --Counter 2 max
                     CLKdiv<= MINVAL(16 downto 0); --Set it back to 0
                     Month<= Month +1;  --Increment month 
                     if(Month ="1100") then --When Month = 12 
                        Month<="0000"; --Reset to 0
                        if(Selector ="1111") then --When Selector is max
                           Selector<="0000"; --Set it back to zero
                     end if;
                end if;
            end if;
        end if;
     end if;
   end if;
      if Selector ="1110" then
          BCD<=D3; --Select for ones digit in days
      elsif Selector ="1101" then
          BCD<=D2; --Select for 10s digit in days
      elsif Selector = "1011" then
          BCD<=D1; --Select for ONEs digit in Months
      elsif Selector ="0111" then
          BCD<=D0; --Select for 10s digit in Months
      end if;
      AN_OFF<="1111"; --Shut off 4 7 segment displays
      SSEG_AN<=Selector; --Use the selector to turn on each Anode
      
 if( Leap = '1' ) then
    case Month is
    when "0000" => D3 <= "0001"; -- 1
    when "0001" => D3 <= "1001";  --9
    when "0010" => D3 <= "0001"; --1
    when "0011" => D3 <= "0000"; --0
    when "0100" => D3 <= "0001"; --1
    when "0101" => D3 <= "0000"; --0
    when "0110" => D3 <= "0001"; --1
    when "0111" => D3 <= "0001"; --1 
    when "1000" => D3 <= "0000"; --0
    when "1001" => D3 <= "0001"; --1
    when "1010" => D3 <= "0001"; --0
    when "1011" => D3 <= "0001"; --1
    when others => D3 <="0000";
    end case;
    else
        case Month is
        when "0000" => D3 <= "0001"; -- 1
        when "0001" => D3 <= "1000";  --8
        when "0010" => D3 <= "0001"; --1
        when "0011" => D3 <= "0000"; --0
        when "0100" => D3 <= "0001"; --1
        when "0101" => D3 <= "0000"; --0
        when "0110" => D3 <= "0001"; --1
        when "0111" => D3 <= "0001"; --1 
        when "1000" => D3 <= "0000"; --0
        when "1001" => D3 <= "0001"; --1
        when "1010" => D3 <= "0001"; --0
        when "1011" => D3 <= "0001"; --1
        when others => D3 <="0000";
        end case;
     end if;
     
 if(Birthday ='1') then
    case Month is
    when "0000" => D3 <= "0001"; -- 1
    when "0001" => D3 <= "1000"; --8
    when "0010" => D3 <= "0001"; --1
    when "0011" => D3 <= "0000"; --0
    when "0100" => D3 <= "0001"; --1
    when "0101" => D3 <= "0000"; --0
    when "0110" => D3 <= "0001"; --1
    when "0111" => D3 <= "0001"; --1 
    when "1000" => D3 <= "0000"; --0
    when "1001" => D3 <= "0001"; --1
    when "1010" => D3 <= "1001"; --9 (NOV)
    when "1011" => D3 <= "0001"; --1
    when others => D3 <="0000";
    end case;
       case Month is
       when "0000" => D2 <= "0011"; -- 3 JAN
       when "0001" => D2 <= "0010";  --2 FEB
       when "0010" => D2 <= "0011"; --3 MAR
       when "0011" => D2 <= "0011"; --3 APR
       when "0100" => D2 <= "0011"; --3 MAY
       when "0101" => D2 <= "0011"; --3 JUN
       when "0110" => D2 <= "0011"; --3 JUL
       when "0111" => D2 <= "0011"; --3  AUG
       when "1000" => D2 <= "0011"; --3 SEP
       when "1001" => D2 <= "0011"; --3 OCT
       when "1010" => D2 <= "0001"; --1 NOV
       when "1011" => D2 <= "0011"; --3 DEC
       when others => D2 <="0000";
       end case;
else
     case Month is
     when "0000" => D3 <= "0001"; -- 1
     when "0001" => D3 <= "1000";  --8
     when "0010" => D3 <= "0001"; --1
     when "0011" => D3 <= "0000"; --0
     when "0100" => D3 <= "0001"; --1
     when "0101" => D3 <= "0000"; --0
     when "0110" => D3 <= "0001"; --1
     when "0111" => D3 <= "0001"; --1 
     when "1000" => D3 <= "0000"; --0
     when "1001" => D3 <= "0001"; --1
     when "1010" => D3 <= "0000"; --0
     when "1011" => D3 <= "0001"; --1
     when others => D3 <="0000";
     end case;

  case Month is
       when "0000" => D2 <= "0011"; -- 3 JAN
       when "0001" => D2 <= "0010";  --2 FEB
       when "0010" => D2 <= "0011"; --3 MAR
       when "0011" => D2 <= "0011"; --3 APR
       when "0100" => D2 <= "0011"; --3 MAY
       when "0101" => D2 <= "0011"; --3 JUN
       when "0110" => D2 <= "0011"; --3 JUL
       when "0111" => D2 <= "0011"; --3  AUG
       when "1000" => D2 <= "0011"; --3 SEP
       when "1001" => D2 <= "0011"; --3 OCT
       when "1010" => D2 <= "0011"; --3 NOV
       when "1011" => D2 <= "0011"; --3 DEC
       when others => D2 <= "0000";
      end case;    
  end if;
 end process;  
     
with Month select
--Used for the 10th digits in the Monthsx   
 D0<=
 "0001" when "1001", --Do is 1 when October (9)
 "0001" when "1010", --D0 is 1 when November  (10)
 "0001" when "1011", --D0 is 1 when December  (11)
 "0000" when others;
 
 with Month select
 --Used for the Ones digits in the Months
 D1<=
 "0001" when "0000", --D1 is 1 when January (0)
 "0010" when "0001", --D1 is 2 when Feb
 "0011" when "0010", --D1 is 3 when Feb
 "0100" when "0011", --D1 is 4 when Apr
 "0101" when "0100", --D1 is 5 when May
 "0110" when "0101", --D1 is 6 when Jun
 "0111" when "0110", --D1 is 7 when July
 "1000" when "0111", --D1 is 8 when Aug
 "1001" when "1000", --D1 is 9 when Sept
 "0000" when "1001", --D1 is 0 when Oct
 "0001" when "1010", --D1 is 1 when Nov
 "0010" when "1011", --D1 is 2 when Dec
 "0000" when others;
   
with BCD select
SSEG_CA<=
     "11000000" when "0000",  --0 Working
     "11111001" when "0001", --1 working
     "10100100" when "0010", --2 working
     "10110000" when "0011", --3 WORKING
     "10011001" when "0100", --4 WORKING
     "10010010" when "0101", --5 WORKING
     "10000010" when "0110", --6 WORKING
     "11111000" when "0111", --7 WORKING
     "10000000" when "1000", --8 WORKING
     "10011000" when "1001", --9 WORKING
     "11111111" when others;  
end Behavioral;