package Widgets.Frames.SocialRaffle
{
   import Classes.TextDecoder;
   import Classes.util.ZLocUtils;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import com.greensock.TweenMax;
   import flash.display.DisplayObject;
   import flash.text.TextField;
   
   public final class RaffleWinningNumberFrame extends ZwFrame
   {
      
      private var m_titleTextField:ZwTextField;
      
      private var m_textDecoder:TextDecoder;
      
      private var m_winningNumberTextFields:Array;
      
      public const DIGIT_DECODE_DURATION:int = 800;
      
      private const DIGIT_COUNT:int = 6;
      
      private const FIXED_DIGIT_COUNT:int = 2;
      
      public function RaffleWinningNumberFrame(element:DisplayObject)
      {
         super(element);
         this.m_textDecoder = new TextDecoder();
         this.setupFrame(element);
      }
      
      override public function release() : void
      {
         this.m_textDecoder.release();
         for(var iDigit:int = 0; iDigit < this.DIGIT_COUNT; iDigit++)
         {
            TweenMax.killTweensOf(this.m_winningNumberTextFields[iDigit]);
         }
         this.m_textDecoder = null;
      }
      
      public function setTitleText(titleText:String) : void
      {
         this.m_titleTextField.text = titleText;
      }
      
      private function setupFrame(element:DisplayObject) : void
      {
         var fieldName:String = null;
         var digitTextField:ZwTextField = null;
         this.m_titleTextField = new ZwTextField(this.element.title_tf,ZLocUtils.t("Dialogs","socialrafflebuilding_game_winningnumber_title"));
         addWidget(this.m_titleTextField);
         this.m_winningNumberTextFields = new Array();
         for(var iDigit:int = 0; iDigit < this.DIGIT_COUNT; iDigit++)
         {
            fieldName = "ticketnumber" + iDigit.toString() + "_tf";
            digitTextField = new ZwTextField(this.element[fieldName]);
            (digitTextField.element as TextField).embedFonts = true;
            this.m_winningNumberTextFields.push(digitTextField);
            addWidget(digitTextField);
         }
      }
      
      public function updateDecodedText(winningNumber:String) : void
      {
         var digit:String = null;
         for(var iDigit:int = 0; iDigit < this.DIGIT_COUNT; iDigit++)
         {
            if(iDigit < winningNumber.length)
            {
               digit = winningNumber.substr(iDigit,1);
               this.m_winningNumberTextFields[iDigit].text = digit;
            }
            else
            {
               this.m_winningNumberTextFields[iDigit].text = "";
            }
         }
      }
      
      public function changeColor(digit:int, color:int = 16711680) : void
      {
         if(digit >= 0 && digit < this.m_winningNumberTextFields.length)
         {
            TweenMax.to(this.m_winningNumberTextFields[digit].element,1,{"colorTransform":{
               "tint":color,
               "tintAmount":0.4
            }});
         }
      }
      
      public function changeColorsAll(color:int = 16777215) : void
      {
         if(color == 16777215)
         {
            this.resetColors();
            return;
         }
         for(var iDigit:int = 0; iDigit < this.DIGIT_COUNT; iDigit++)
         {
            TweenMax.to(this.m_winningNumberTextFields[iDigit].element,1,{"colorTransform":{
               "tint":color,
               "tintAmount":0.4
            }});
         }
      }
      
      public function resetColors() : void
      {
         for(var iDigit:int = 0; iDigit < this.DIGIT_COUNT; iDigit++)
         {
            TweenMax.to(this.m_winningNumberTextFields[iDigit].element,1,{"removeTint":true});
         }
      }
      
      public function startDecoding(winningNumber:String, digitCallback:Function, completeCallback:Function) : void
      {
         var digitDecodeTimes:Array = [];
         for(var i:int = 0; i < winningNumber.length; i++)
         {
            if(i <= this.FIXED_DIGIT_COUNT)
            {
               digitDecodeTimes.push(this.DIGIT_DECODE_DURATION);
            }
            else
            {
               digitDecodeTimes.push(this.DIGIT_DECODE_DURATION * (i * 2 + 1 - winningNumber.length));
            }
         }
         this.m_textDecoder.startDecode(winningNumber,digitDecodeTimes,digitCallback,completeCallback,this.updateDecodedText);
      }
      
      public function skipDecoding() : void
      {
         this.m_textDecoder.instantDecode();
      }
   }
}

