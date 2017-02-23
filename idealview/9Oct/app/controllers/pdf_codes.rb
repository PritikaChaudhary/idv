canvas do
      bounding_box([0,750], :width => 500, :height => 100) do
     stroke_bounds
      text("hello \n<i>how are</i></b> you? <u>how are you</u> now? Lorem Ipsum is a dummy text
        Lorem Ipsum is a dummy text Lorem Ipsum is a dummy textLorem Ipsum is a dummy textLorem Ipsum is a dummy text
        Lorem Ipsum is a dummy text Lorem Ipsum is a dummy textLorem Ipsum is a dummy textLorem Ipsum is a dummy text
        Lorem Ipsum is a dummy textLorem Ipsum is a dummy textLorem Ipsum is a dummy textLorem Ipsum is a dummy text
        Lorem Ipsum is a dummy textLorem Ipsum is a dummy textLorem Ipsum is a dummy textLorem Ipsum is a dummy text
        Lorem Ipsum is a dummy textLorem Ipsum is a dummy textLorem Ipsum is a dummy textLorem Ipsum is a dummy text
        Lorem Ipsum is a dummy textLorem Ipsum is a dummy textLorem Ipsum is a dummy textLorem Ipsum is a dummy text
        Lorem Ipsum is a dummy textLorem Ipsum is a dummy textLorem Ipsum is a dummy textLorem Ipsum is a dummy text
        Lorem Ipsum is a dummy textLorem Ipsum is a dummy textLorem Ipsum is a dummy textLorem Ipsum is a dummy text
        Lorem Ipsum is a dummy text",
        :inline_format => true)
     end
   end
 stroke_horizontal_rule
      pad(20){text"Text padded both before and after."}

///////////////////////////////////////////////////////////
move_down 30

      canvas do
      bounding_box([0,cursor], :width => 500) do
    
      text("hello \n<i>how are</i></b> you? <u>how are you</u> now? Lorem Ipsum is a dummy text
        Lorem Ipsum is a dummy text Lorem Ipsum is a dummy textLorem Ipsum is a dummy textLorem Ipsum is a dummy text
        Lorem Ipsum is a dummy text Lorem Ipsum is a dummy textLorem Ipsum is a dummy textLorem Ipsum is a dummy text
        Lorem Ipsum is a dummy textLorem Ipsum is a dummy textLorem Ipsum is a dummy textLorem Ipsum is a dummy text
        Lorem Ipsum is a dummy textLorem Ipsum is a dummy textLorem Ipsum is a dummy textLorem Ipsum is a dummy text
        Lorem Ipsum is a dummy textLorem Ipsum is a dummy textLorem Ipsum is a dummy textLorem Ipsum is a dummy text
        Lorem Ipsum is a dummy textLorem Ipsum is a dummy textLorem Ipsum is a dummy textLorem Ipsum is a dummy text
        Lorem Ipsum is a dummy textLorem Ipsum is a dummy textLorem Ipsum is a dummy textLorem Ipsum is a dummy text
        Lorem Ipsum is a dummy textLorem Ipsum is a dummy textLorem Ipsum is a dummy textLorem Ipsum is a dummy text
        Lorem Ipsum is a dummy text",
        :inline_format => true)
         stroke_bounds
       end
          bounding_box([0,cursor], :width => 500) do

         text("hello \n<i>how are</i></b> you? <u>how are you</u> now? Lorem Ipsum is a dummy text
        Lorem Ipsum is a dummy text Lorem Ipsum is a dummy textLorem Ipsum is a dummy textLorem Ipsum is a dummy text
        Lorem Ipsum is a dummy text Lorem Ipsum is a dummy textLorem Ipsum is a dummy textLorem Ipsum is a dummy text
        Lorem Ipsum is a dummy textLorem Ipsum is a dummy textLorem Ipsum is a dummy textLorem Ipsum is a dummy text
        Lorem Ipsum is a dummy textLorem Ipsum is a dummy textLorem Ipsum is a dummy textLorem Ipsum is a dummy text
        Lorem Ipsum is a dummy textLorem Ipsum is a dummy textLorem Ipsum is a dummy textLorem Ipsum is a dummy text
        Lorem Ipsum is a dummy textLorem Ipsum is a dummy textLorem Ipsum is a dummy textLorem Ipsum is a dummy text
        Lorem Ipsum is a dummy textLorem Ipsum is a dummy textLorem Ipsum is a dummy textLorem Ipsum is a dummy text
        Lorem Ipsum is a dummy textLorem Ipsum is a dummy textLorem Ipsum is a dummy textLorem Ipsum is a dummy text
        Lorem Ipsum is a dummy text",
        :inline_format => true)
        stroke_bounds
     end
   end
////////////////////////////////////////////////

   stroke do
  stroke_color 'ff0000'
 # dash(5, space: 2, phase: 0)
  line_width 5
  stroke_horizontal_rule
  #move_down 15
  horizontal_line(0, 540)
end

       span(350, :position => :center) do
   text "Here's some centered text in a 350 point column. " * 100
 end

/////////////////////////////////////////////////////////


       canvas do
        indent 10, 10 do
          image filename, :width=>150, :at => [0, cursor]
          move_down 17
          today=Time.new
          str_time=today.strftime("%d/%m/%Y")
          draw_text "Pipeline Summary "+str_time, :at => [438,cursor]
          move_down 20
          @loans = Loan.find(ids)

          @loans.map do |loan|
            a=""
            unless loan.info['City3'].blank?
              a += loan.info['City3']
            end
            unless loan.info['State3'].blank?
              a += ", "+ loan.info['State3']
            end

            unless loan.info['_NetLoanAmountRequested0'].blank?
              amnt="$ "+loan.info['_NetLoanAmountRequested0'].to_s
            else
              amnt="N/A"
            end

            unless loan.info['_LoanSummaryWhatareyoulookingfor'].blank?
              summary=loan.info['_LoanSummaryWhatareyoulookingfor']
            else
              summary=""
            end

            bounding_box([0,cursor], :width => 592) do
              move_down 5
              indent 5, 5 do
              if a!=""
                text("<b>"+loan.name+" | "+a+"\n Loan Amount: </b>"+amnt+"\n <b>Summary: </b>"+summary,
                :inline_format => true)
              else
                text("<b>"+loan.name+"\n Loan Amount: </b>"+amnt+"\n <b> Summary: </b>"+summary,
                :inline_format => true)
              end
              end
              stroke_bounds
            end
            move_down 20
          end
        end
     end
    end