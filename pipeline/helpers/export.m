classdef export
    %IO Summary of this class goes here
    %   Detailed explanation goes here
    
    properties
    end
    
    methods (Static)
        
        function [ vars ] = tblGrep( T, term )
            %TBLGREP Summary of this function goes here
            %   Detailed explanation goes here
            
            input = T.Properties.VariableNames;
            outidx = cellfun('length', regexp(input, term, 'ignorecase')) > 0;
            vars = input(outidx);
        end
        
        function arrayHist(T, plotVars, binWidth, x_values, inner_padding)
            nPlots = numel(plotVars)/2;
            for i = 1:(nPlots*2)
                if mod(i,2) == 0
                    subplot_tight(nPlots,nPlots,i-1, inner_padding);
                else
                    subplot_tight(nPlots,nPlots,i, inner_padding);
                end
                h = histogram(T.(plotVars{i}));
                hold on
                h.BinWidth = binWidth;
                h.Normalization = 'pdf';
                pd = fitdist(T.(plotVars{i}),'Kernel', 'Width', 0.05);
                %x_values = 0.1:0.01:1.2;
                y = pdf(pd,x_values);
                plot(x_values,y);
            end;
        end
        
        function p = histValidity(T, binWidth, exp_long)
            rt_vars = export.tblGrep(T, 'meanRT');
            T = varfun(@(x) x*1000, T(:,rt_vars), 'OutputFormat', 'table');
            exp = 'Rp';
            exp_long = 'Response Priming';
            binWidth = 50;
            
            x_values = 100:10:1200;
            inner_padding = [0.09, 0.08];
            method = 'count';
            
            a = subplot_tight(2,2,1, inner_padding);
            yyaxis left
           
            a.YColor = 'black';
            hv = histogram(T.(['Fun_AN_val_meanRT_' exp]), 'BinWidth', binWidth);
            a.YLim = [0,10];
            hv.Normalization = method;
            hv.FaceColor = 'black';
            ylabel('counts (bars)');
            xlabel('reaction time (ms)');
            pd = fitdist(T.(['Fun_AN_val_meanRT_' exp]),'Kernel', 'Width', 50);
            y = pdf(pd,x_values);
            hold on
            
            hiv = histogram(T.(['Fun_AN_inval_meanRT_' exp]), 'BinWidth', binWidth);
           
            yyaxis right
            a.YColor = 'black';
            %ylabel('probability density');
            p = plot(x_values,y, 'Color','black', 'LineWidth', 2);
            hiv.Normalization = method;
            hiv.FaceColor = 'magenta';
            pd = fitdist(T.(['Fun_AN_inval_meanRT_' exp]),'Kernel', 'Width', 50);
            y = pdf(pd,x_values);
            p = plot(x_values,y, 'Color','magenta', 'LineWidth', 2, 'LineStyle', '-');
            title(['Reaction Times ' exp_long ': Anger valid vs invalid']);
            legend([hv, hiv], {'valid', 'invalid'});
            
            b = subplot_tight(2,2,2, inner_padding);
            
            yyaxis left
            b.YColor = 'black';
            hv = histogram(T.(['Fun_HA_val_meanRT_' exp]), 'BinWidth', binWidth);
            b.YLim = [0,10];
            hv.Normalization = method;
            hv.FaceColor = 'black';
            
            pd = fitdist(T.(['Fun_HA_val_meanRT_' exp]),'Kernel', 'Width', 50);
            y = pdf(pd,x_values);
            hold on
            
            hiv2 = histogram(T.(['Fun_HA_inval_meanRT_' exp]), 'BinWidth', binWidth);
           
            yyaxis right
            b.YColor = 'black';
            ylabel('probability density (lines)');
            xlabel('reaction time (ms)');
            p = plot(x_values,y, 'Color','black', 'LineWidth', 2);
            hiv2.Normalization = method;
            hiv2.FaceColor = 'magenta';
            pd = fitdist(T.(['Fun_HA_inval_meanRT_' exp]),'Kernel', 'Width', 50);
            y = pdf(pd,x_values);
            p = plot(x_values,y, 'Color','magenta', 'LineWidth', 2, 'LineStyle', '-');
            title(['Reaction Times ' exp_long ': Happiness/Joy repetition vs switch']);
            legend([hv, hiv2], {'repetition', 'switch'});
            
            
            exp = 'Ts';
            exp_long = 'Response Switching';
            
            x_values = 100:10:1200;
            inner_padding = [0.09, 0.08];
            method = 'count';
            
            a = subplot_tight(2,2,3, inner_padding);
            yyaxis left
           
            a.YColor = 'black';
            hv = histogram(T.(['Fun_AN_val_meanRT_' exp]), 'BinWidth', binWidth);
            a.YLim = [0,13];
            hv.Normalization = method;
            hv.FaceColor = 'black';
            ylabel('counts (bars)');
            xlabel('reaction time (ms)');
            pd = fitdist(T.(['Fun_AN_val_meanRT_' exp]),'Kernel', 'Width', 50);
            y = pdf(pd,x_values);
            hold on
            
            hiv = histogram(T.(['Fun_AN_inval_meanRT_' exp]), 'BinWidth', binWidth);
           
            yyaxis right
            a.YColor = 'black';
            %ylabel('probability density');
            p = plot(x_values,y, 'Color','black', 'LineWidth', 2);
            hiv.Normalization = method;
            hiv.FaceColor = 'magenta';
            pd = fitdist(T.(['Fun_AN_inval_meanRT_' exp]),'Kernel', 'Width', 50);
            y = pdf(pd,x_values);
            p = plot(x_values,y, 'Color','magenta', 'LineWidth', 2, 'LineStyle', '-');
            title(['Reaction Times ' exp_long ': Anger valid vs invalid']);
            legend([hv, hiv], {'valid', 'invalid'});
            
            b = subplot_tight(2,2,4, inner_padding);
            
            yyaxis left
            b.YColor = 'black';
            hv = histogram(T.(['Fun_HA_val_meanRT_' exp]), 'BinWidth', binWidth);
            b.YLim = [0,13];
            hv.Normalization = method;
            hv.FaceColor = 'black';
            
            pd = fitdist(T.(['Fun_HA_val_meanRT_' exp]),'Kernel', 'Width', 50);
            y = pdf(pd,x_values);
            hold on
            
            hiv2 = histogram(T.(['Fun_HA_inval_meanRT_' exp]), 'BinWidth', binWidth);
           
            yyaxis right
            b.YColor = 'black';
            ylabel('probability density (lines)');
            xlabel('reaction time (ms)');
            p = plot(x_values,y, 'Color','black', 'LineWidth', 2);
            hiv2.Normalization = method;
            hiv2.FaceColor = 'magenta';
            pd = fitdist(T.(['Fun_HA_inval_meanRT_' exp]),'Kernel', 'Width', 50);
            y = pdf(pd,x_values);
            p = plot(x_values,y, 'Color','magenta', 'LineWidth', 2, 'LineStyle', '-');
            title(['Reaction Times ' exp_long ': Happiness/Joy repetition vs switch']);
            legend([hv, hiv2], {'repetition', 'switch'});
            
            %linkaxes([a,b],'y');
        end
    end
end
