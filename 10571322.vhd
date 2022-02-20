library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use ieee.numeric_std.all;


entity project_reti_logiche is
    port(
        i_clk           : in std_logic;
        i_start         : in std_logic;
        i_rst           : in std_logic;
        i_data          : in std_logic_vector(7 downto 0);
        o_address       : out std_logic_vector(15 downto 0);
        o_done          : out std_logic;
        o_en            : out std_logic;
        o_we            : out std_logic;
        o_data          : out std_logic_vector(7 downto 0)
        );
end project_reti_logiche;

architecture behavioral of project_reti_logiche is
    type state_type is (Reset, Wait1, Wait2, Reg1, Reg2, Reg3, Reg4, Reg5, Reg6, Reg7, Reg8, Elaborazione_dato, Salvataggio_dato, Conclusione, Ricomincia, Ricomincia2);
-- Gli stati con Reg davanti hanno lo scopo di eseguire il salvataggio dei valori da RAM(0) a RAM(7) (ovvero i valori delle
-- cosidette Working Zone), ognuno in un registro diverso.

-- Lo stato Elaborazione_dato ha lo scopo di eseguire le operazioni e verificare se il valore contenuto in RAM(8), faccia parte di
-- una Warning Zone o meno.

-- Nello stato Salvataggio_dato si effettua l'assegnazione del valore corretto da assegnare in RAM(9), mentre lo stato Conclusione
-- serve per lasciare tempo al dato per essere salvato in memoria e infine per impostare o_done = '1'.

-- Gli ultimi due stati Ricomincia e Ricomincia2 formano un ciclo che ha lo scopo di aspettare il segnale di i_start = '1',
-- oppure un segnale i_rst = '1'.
    signal next_state, current_state: state_type;
    signal registro1            : std_logic_vector(7 downto 0) := "00000000";
    signal registro1_next       : std_logic_vector(7 downto 0) := "00000000";
    signal registro2            : std_logic_vector(7 downto 0) := "00000000";
    signal registro2_next       : std_logic_vector(7 downto 0) := "00000000";
    signal registro3            : std_logic_vector(7 downto 0) := "00000000";
    signal registro3_next       : std_logic_vector(7 downto 0) := "00000000";
    signal registro4            : std_logic_vector(7 downto 0) := "00000000";
    signal registro4_next       : std_logic_vector(7 downto 0) := "00000000";
    signal registro5            : std_logic_vector(7 downto 0) := "00000000";
    signal registro5_next       : std_logic_vector(7 downto 0) := "00000000";
    signal registro6            : std_logic_vector(7 downto 0) := "00000000";
    signal registro6_next       : std_logic_vector(7 downto 0) := "00000000";
    signal registro7            : std_logic_vector(7 downto 0) := "00000000";
    signal registro7_next       : std_logic_vector(7 downto 0) := "00000000";
    signal registro8            : std_logic_vector(7 downto 0) := "00000000";
    signal registro8_next       : std_logic_vector(7 downto 0) := "00000000";
-- I signal da registro1 a registro8 sono riservati a contenere i valori della RAM da RAM(0) a RAM(7).
    signal wz_bit               : std_logic := '0';
    signal wz_bit_next          : std_logic := '0';
    signal wz_num               : std_logic_vector(2 downto 0) := "000";
    signal wz_num_next          : std_logic_vector(2 downto 0) := "000";
    signal wz_offset            : std_logic_vector(3 downto 0) := "0000";
    signal wz_offset_next       : std_logic_vector(3 downto 0) := "0000";
-- I segnali wz_bit, wz_num e wz_offset hanno lo scopo di registrare il valore che alla fine verrà concatenato.
    signal valore               : std_logic_vector(7 downto 0) := "00000000";
    signal valore_next          : std_logic_vector(7 downto 0) := "00000000";
-- Il segnale valore serve a salvare il contenuto di RAM(8), nel caso esso non sia contenuto in nessuna Working Zone.
    signal is_in                : std_logic := '0';
    signal is_in_next           : std_logic := '0';
-- Il segnal is_in verrà impostato ad 1 quando il valore in RAM(8) è contenuto in una Working Zone.

-- I segnali con "_next", servono per risolvere gli warning di inferring latch sui segnali stessi.

begin
    state_reg: process(i_rst, i_clk)
    begin
-- Definizione degli stati
        if i_rst = '1' then
            current_state <= Reset;
        elsif rising_edge(i_clk) then
            current_state <= next_state;
            registro1_next <= registro1;
            registro2_next <= registro2;
            registro3_next <= registro3;
            registro4_next <= registro4;
            registro5_next <= registro5;
            registro6_next <= registro6;
            registro7_next <= registro7;
            registro8_next <= registro8;
            wz_bit_next <= wz_bit;
            wz_num_next <= wz_num;
            wz_offset_next <= wz_offset;
            valore_next <= valore;
            is_in_next <= is_in;
        end if;
    end process;
    
    lambda: process(current_state, i_start)
    begin
        case current_state is
            when Reset =>
                next_state <= Wait1;
            when Wait1 =>
                if i_start = '1' then
                    next_state <= Reg1;
                else
                    next_state <= Wait2;
                end if;
            when Wait2 =>
                if i_start = '1' then
                    next_state <= Reg1;
                else
                    next_state <= Wait1;
                end if;
            when Reg1 =>
                next_state <= Reg2;
            
            when Reg2 =>
                next_state <= Reg3;
            
            when Reg3 =>
                next_state <= Reg4;
            
            when Reg4 =>
                next_state <= Reg5;
            
            when Reg5 =>
                next_state <= Reg6;
            
            when Reg6 =>
                next_state <= Reg7;
            
            when Reg7 =>
                next_state <= Reg8;
            
            when Reg8 =>
                next_state <= Elaborazione_dato;
            
            when Elaborazione_dato =>
                next_state <= Salvataggio_dato;
            
            when Salvataggio_dato =>
                next_state <= Conclusione;
            when Conclusione =>
                next_state <= Ricomincia;
            
            when Ricomincia =>
                if i_start = '1' then
                    next_state <= Elaborazione_dato;
                else
                    next_state <= Ricomincia2;
                end if;
            when Ricomincia2 =>
                if i_start = '1' then
                    next_state <= Elaborazione_dato;
                else
                    next_state <= Ricomincia;
                end if;
        end case;
    end process;

-- Nella tabella di sensitività del processo delta inserisco tutte le signal che uso al suo interno.    
    delta: process(current_state, i_data, registro1, registro1_next, registro2, registro2_next, registro3, registro3_next, registro4, registro4_next, registro5, registro5_next, registro6, registro6_next, registro7, registro7_next, registro8, registro8_next, wz_bit, wz_bit_next, wz_num, wz_num_next, wz_offset, wz_offset_next, valore, valore_next, is_in, is_in_next)
    variable temp1          : std_logic_vector(7 downto 0);
    variable temp2          : std_logic_vector(7 downto 0);
    variable temp3          : std_logic_vector(7 downto 0);
    variable temp4          : std_logic_vector(7 downto 0);
    variable temp5          : std_logic_vector(7 downto 0);
    variable temp6          : std_logic_vector(7 downto 0);
    variable temp7          : std_logic_vector(7 downto 0);
    variable temp8          : std_logic_vector(7 downto 0);
-- Le variabili da temp1 a temp8 hanno lo scopo di memorizzare le sottrazioni tra il valore contenuto in RAM(8) ed i valori
-- contenuti nei vari registri (che corrispondono alle varie Working Zone).

-- Per evitare gli warning di inferring latch devo assegnare in ogni stato un valore per tutte le signal che utilizzo
-- (nella maggior parte dei casi i valori assegnati saranno quelli precedenti oppure 0).
    begin
        case current_state is
            when Reset =>
                o_address <= "0000000000000000";
                o_en <= '1';
                o_we <= '0';
                is_in <= '0';
                valore <= "00000000";
                registro1 <= (others => '0');
                registro2 <= (others => '0');
                registro3 <= (others => '0');
                registro4 <= (others => '0');
                registro5 <= (others => '0');
                registro6 <= (others => '0');
                registro7 <= (others => '0');
                registro8 <= (others => '0');
                wz_bit <= '0';
                wz_num <= "000";
                wz_offset <= "0000";
                o_done <= '0';
                o_data <= "00000000";
            when Wait1 =>
                o_address <= "0000000000000000";
                o_en <= '1';
                o_we <= '0';
                is_in <= '0';
                valore <= "00000000";
                registro1 <= (others => '0');
                registro2 <= (others => '0');
                registro3 <= (others => '0');
                registro4 <= (others => '0');
                registro5 <= (others => '0');
                registro6 <= (others => '0');
                registro7 <= (others => '0');
                registro8 <= (others => '0');
                wz_bit <= '0';
                wz_num <= "000";
                wz_offset <= "0000";
                o_done <= '0';
                o_data <= "00000000";
            when Wait2 =>
                o_address <= "0000000000000000";
                o_en <= '1';
                o_we <= '0';
                is_in <= '0';
                valore <= "00000000";
                registro1 <= (others => '0');
                registro2 <= (others => '0');
                registro3 <= (others => '0');
                registro4 <= (others => '0');
                registro5 <= (others => '0');
                registro6 <= (others => '0');
                registro7 <= (others => '0');
                registro8 <= (others => '0');
                wz_bit <= '0';
                wz_num <= "000";
                wz_offset <= "0000";
                o_done <= '0';
                o_data <= "00000000";
            
            when Reg1 =>
                registro1 <= i_data;
                o_address <= "0000000000000001";
                o_en <= '1';
                o_we <= '0';
                is_in <= '0';
                valore <= "00000000";
                registro2 <= (others => '0');
                registro3 <= (others => '0');
                registro4 <= (others => '0');
                registro5 <= (others => '0');
                registro6 <= (others => '0');
                registro7 <= (others => '0');
                registro8 <= (others => '0');
                wz_bit <= '0';
                wz_num <= "000";
                wz_offset <= "0000";
                o_done <= '0';
                o_data <= "00000000";
            
            when Reg2 =>
                registro2 <= i_data;
                o_address <= "0000000000000010";
                o_en <= '1';
                o_we <= '0';
                is_in <= '0';
                valore <= "00000000";
                registro1 <= registro1_next;
                registro3 <= (others => '0');
                registro4 <= (others => '0');
                registro5 <= (others => '0');
                registro6 <= (others => '0');
                registro7 <= (others => '0');
                registro8 <= (others => '0');
                wz_bit <= '0';
                wz_num <= "000";
                wz_offset <= "0000";
                o_done <= '0';
                o_data <= "00000000";
            
            when Reg3 =>
                registro3 <= i_data;
                o_address <= "0000000000000011";
                o_en <= '1';
                o_we <= '0';
                is_in <= '0';
                valore <= "00000000";
                registro1 <= registro1_next;
                registro2 <= registro2_next;
                registro4 <= (others => '0');
                registro5 <= (others => '0');
                registro6 <= (others => '0');
                registro7 <= (others => '0');
                registro8 <= (others => '0');
                wz_bit <= '0';
                wz_num <= "000";
                wz_offset <= "0000";
                o_done <= '0';
                o_data <= "00000000";
            
            when Reg4 =>
                registro4 <= i_data;
                o_address <= "0000000000000100";
                o_en <= '1';
                o_we <= '0';
                is_in <= '0';
                valore <= "00000000";
                registro1 <= registro1_next;
                registro2 <= registro2_next;
                registro3 <= registro3_next;
                registro5 <= (others => '0');
                registro6 <= (others => '0');
                registro7 <= (others => '0');
                registro8 <= (others => '0');
                wz_bit <= '0';
                wz_num <= "000";
                wz_offset <= "0000";
                o_done <= '0';
                o_data <= "00000000";
            
            when Reg5 =>
                registro5 <= i_data;
                o_address <= "0000000000000101";
                o_en <= '1';
                o_we <= '0';
                is_in <= '0';
                valore <= "00000000";
                registro1 <= registro1_next;
                registro2 <= registro2_next;
                registro3 <= registro3_next;
                registro4 <= registro4_next;
                registro6 <= (others => '0');
                registro7 <= (others => '0');
                registro8 <= (others => '0');
                wz_bit <= '0';
                wz_num <= "000";
                wz_offset <= "0000";
                o_done <= '0';
                o_data <= "00000000";
            
            when Reg6 =>
                registro6 <= i_data;
                o_address <= "0000000000000110";
                o_en <= '1';
                o_we <= '0';
                is_in <= '0';
                valore <= "00000000";
                registro1 <= registro1_next;
                registro2 <= registro2_next;
                registro3 <= registro3_next;
                registro4 <= registro4_next;
                registro5 <= registro5_next;
                registro7 <= (others => '0');
                registro8 <= (others => '0');
                wz_bit <= '0';
                wz_num <= "000";
                wz_offset <= "0000";
                o_done <= '0';
                o_data <= "00000000";
            
            when Reg7 =>
                registro7 <= i_data;
                o_address <= "0000000000000111";
                o_en <= '1';
                o_we <= '0';
                is_in <= '0';
                valore <= "00000000";
                registro1 <= registro1_next;
                registro2 <= registro2_next;
                registro3 <= registro3_next;
                registro4 <= registro4_next;
                registro5 <= registro5_next;
                registro6 <= registro6_next;
                registro8 <= (others => '0');
                wz_bit <= '0';
                wz_num <= "000";
                wz_offset <= "0000";
                o_done <= '0';
                o_data <= "00000000";
            
            when Reg8 =>
                o_address <= "0000000000001000";
                registro8 <= i_data;
                o_en <= '1';
                o_we <= '0';
                is_in <= '0';
                valore <= "00000000";
                registro1 <= registro1_next;
                registro2 <= registro2_next;
                registro3 <= registro3_next;
                registro4 <= registro4_next;
                registro5 <= registro5_next;
                registro6 <= registro6_next;
                registro7 <= registro7_next;
                wz_bit <= '0';
                wz_num <= "000";
                wz_offset <= "0000";
                o_done <= '0';
                o_data <= "00000000";
            
-- Nello stato Elaborazione_dato, prima faccio le sottrazioni tra il valore in posizione 8 con tutti i valori delle Working Zone che mi
-- sono salvato al punto precedente ed in seguito, controllo se i valori che mi sono ricavato siano compresi tra 0 e 3 
-- (compresi).
-- Facendo questo passaggio ho la certezza che valori che mi sono ricavato siano al 100% dentro la Working Zone rispetto
-- alla quale sto facendo il calcolo; se alla fine trovo che l'indirizzo si trova dentro una Working Zone, allora 
-- impongo wz_bit = 1, wz_num = numero della Working Zone rispetto alla quale ho trovato il valore e wz_offset = offset 
-- rispetto all'indirizzo di base della Working Zone, peró codificato come one-hot. Altrimenti imposto solamente wz_bit = 0.
            when Elaborazione_dato =>
                o_data <= "00000000";
                o_en <= '1';
                o_we <= '1';
                temp1 := std_logic_vector(SIGNED(i_data) - SIGNED(registro1));
                temp2 := std_logic_vector(SIGNED(i_data) - SIGNED(registro2));
                temp3 := std_logic_vector(SIGNED(i_data) - SIGNED(registro3));
                temp4 := std_logic_vector(SIGNED(i_data) - SIGNED(registro4));
                temp5 := std_logic_vector(SIGNED(i_data) - SIGNED(registro5));
                temp6 := std_logic_vector(SIGNED(i_data) - SIGNED(registro6));
                temp7 := std_logic_vector(SIGNED(i_data) - SIGNED(registro7));
                temp8 := std_logic_vector(SIGNED(i_data) - SIGNED(registro8));
                valore <= i_data;
-- 0 <= (i_data - registro) <= 3      ->      operazione per verificare che i_data sia interno alla Working Zone.
                if temp1 >= "00000000" and temp1 <= "00000011" then
                    is_in <= '1';
                    wz_bit <= '1';
                    wz_num <= "000";
                    case temp1 is
                        when "00000000" => wz_offset <= "0001";
                        when "00000001" => wz_offset <= "0010";
                        when "00000010" => wz_offset <= "0100";
                        when others => wz_offset <= "1000";
                    end case;
                
                elsif temp2 >= "00000000" and temp2 <= "00000011" then
                    is_in <= '1';
                    wz_bit <= '1';
                    wz_num <= "001";
                    case temp2 is
                        when "00000000" => wz_offset <= "0001";
                        when "00000001" => wz_offset <= "0010";
                        when "00000010" => wz_offset <= "0100";
                        when others => wz_offset <= "1000";
                    end case;
                
                elsif temp3 >= "00000000" and temp3 <= "00000011" then
                    is_in <= '1';
                    wz_bit <= '1';
                    wz_num <= "010";
                    case temp3 is
                        when "00000000" => wz_offset <= "0001";
                        when "00000001" => wz_offset <= "0010";
                        when "00000010" => wz_offset <= "0100";
                        when others => wz_offset <= "1000";
                    end case;   
                
                elsif temp4 >= "00000000" and temp4 <= "00000011" then
                    is_in <= '1';
                    wz_bit <= '1';
                    wz_num <= "011";
                    case temp4 is
                        when "00000000" => wz_offset <= "0001";
                        when "00000001" => wz_offset <= "0010";
                        when "00000010" => wz_offset <= "0100";
                        when others => wz_offset <= "1000";
                    end case;
                
                elsif temp5 >= "00000000" and temp5 <= "00000011" then
                    is_in <= '1';
                    wz_bit <= '1';
                    wz_num <= "100";
                    case temp5 is
                        when "00000000" => wz_offset <= "0001";
                        when "00000001" => wz_offset <= "0010";
                        when "00000010" => wz_offset <= "0100";
                        when others => wz_offset <= "1000";
                    end case;
                
                elsif temp6 >= "00000000" and temp6 <= "00000011" then
                    is_in <= '1';
                    wz_bit <= '1';
                    wz_num <= "101";
                    case temp6 is
                        when "00000000" => wz_offset <= "0001";
                        when "00000001" => wz_offset <= "0010";
                        when "00000010" => wz_offset <= "0100";
                        when others => wz_offset <= "1000";
                    end case;
                
                elsif temp7 >= "00000000" and temp7 <= "00000011" then
                    is_in <= '1';
                    wz_bit <= '1';
                    wz_num <= "110";
                    case temp7 is
                       when "00000000" => wz_offset <= "0001";
                        when "00000001" => wz_offset <= "0010";
                        when "00000010" => wz_offset <= "0100";
                        when others => wz_offset <= "1000";
                    end case;
                
                elsif temp8 >= "00000000" and temp8 <= "00000011" then
                    is_in <= '1';
                    wz_bit <= '1';
                    wz_num <= "111";
                    case temp8 is
                        when "00000000" => wz_offset <= "0001";
                        when "00000001" => wz_offset <= "0010";
                        when "00000010" => wz_offset <= "0100";
                        when others => wz_offset <= "1000";
                    end case;
                
                else
                    is_in <= '0';
                    wz_bit <= '0';
                    wz_num <= "000";
                    wz_offset <= "0000";
                end if;
                o_address <= "0000000000001001";
                registro1 <= registro1_next;
                registro2 <= registro2_next;
                registro3 <= registro3_next;
                registro4 <= registro4_next;
                registro5 <= registro5_next;
                registro6 <= registro6_next;
                registro7 <= registro7_next;
                registro8 <= registro8_next;
                o_done <= '0';
            
-- Lo stato Salvataggio_dato fa il controllo e assegna i valore in o_data in base al segnle di is_in.
            when Salvataggio_dato =>
                if is_in = '1' then
                    o_data <= wz_bit & wz_num & wz_offset;
                else
                    o_data <= valore;
                end if;
                o_address <= "0000000000001001";
                o_en <= '1';
                o_we <= '1';
                registro1 <= registro1_next;
                registro2 <= registro2_next;
                registro3 <= registro3_next;
                registro4 <= registro4_next;
                registro5 <= registro5_next;
                registro6 <= registro6_next;
                registro7 <= registro7_next;
                registro8 <= registro8_next;
                wz_bit <= wz_bit_next;
                wz_num <= wz_num_next;
                wz_offset <= wz_offset_next;
                valore <= valore_next;
                is_in <= is_in_next;
                o_done <= '0';
            when Conclusione =>
                if is_in = '1' then
                    o_data <= wz_bit & wz_num & wz_offset;
                else
                    o_data <= valore;
                end if;
                o_address <= "0000000000001001";
                o_en <= '1';
                o_we <= '0';
                is_in <= is_in_next;
                registro1 <= registro1_next;
                registro2 <= registro2_next;
                registro3 <= registro3_next;
                registro4 <= registro4_next;
                registro5 <= registro5_next;
                registro6 <= registro6_next;
                registro7 <= registro7_next;
                registro8 <= registro8_next;
                wz_bit <= wz_bit_next;
                wz_num <= wz_num_next;
                wz_offset <= wz_offset_next;
                valore <= valore_next;
                o_done <= '1';
                
            when Ricomincia =>
                o_data <= "00000000";
                o_address <= "0000000000001000";
                registro1 <= registro1_next;
                registro2 <= registro2_next;
                registro3 <= registro3_next;
                registro4 <= registro4_next;
                registro5 <= registro5_next;
                registro6 <= registro6_next;
                registro7 <= registro7_next;
                registro8 <= registro8_next;
                wz_bit <= '0';
                wz_num <= "000";
                wz_offset <= "0000";
                o_en <= '1';
                o_we <= '0';
                is_in <= '0';
                valore <= "00000000";
                o_done <= '0';
            when Ricomincia2 =>
                o_data <= "00000000";
                o_address <= "0000000000001000";
                registro1 <= registro1_next;
                registro2 <= registro2_next;
                registro3 <= registro3_next;
                registro4 <= registro4_next;
                registro5 <= registro5_next;
                registro6 <= registro6_next;
                registro7 <= registro7_next;
                registro8 <= registro8_next;
                wz_bit <= '0';
                wz_num <= "000";
                wz_offset <= "0000";
                o_en <= '1';
                o_we <= '0';
                is_in <= '0';
                valore <= "00000000";
                o_done <= '0';
        end case;
    end process;
end behavioral;