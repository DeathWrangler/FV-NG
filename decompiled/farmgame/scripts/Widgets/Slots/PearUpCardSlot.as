package Widgets.Slots
{
   import Engine.Managers.ErrorManager;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Windows.FarmWindow;
   import Widgets.Windows.PearUp.PearUpWindow;
   import com.greensock.TweenLite;
   import com.greensock.TweenMax;
   import com.greensock.easing.Elastic;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   
   public class PearUpCardSlot extends ZwSlotFrame
   {
      
      private var m_parentWindow:PearUpWindow;
      
      private var m_matchEffect:ZwFrame = null;
      
      private var m_noMatch:ZwFrame = null;
      
      private var m_image:ZwFrame = null;
      
      private var m_matched:ZwFrame = null;
      
      private var m_clicked:ZwFrame = null;
      
      private var m_back:ZwFrame = null;
      
      public function PearUpCardSlot(element:DisplayObject, parentWindow:FarmWindow)
      {
         super(element);
         if(parentWindow is PearUpWindow)
         {
            this.m_parentWindow = parentWindow as PearUpWindow;
            m_element.mouseEnabled = true;
            m_element.buttonMode = true;
            m_element.addEventListener(MouseEvent.CLICK,this.onClick);
            m_element.addEventListener(MouseEvent.ROLL_OVER,this.onRollOver);
            m_element.addEventListener(MouseEvent.ROLL_OUT,this.onRollOut);
            if(m_element.effect_mc == null || m_element.noMatch_mc == null || m_element.image_mc == null || m_element.matched_mc == null || m_element.clicked_mc == null || m_element.back_mc == null)
            {
               ErrorManager.addError("PearUpCardSlot, constructor() error: required MovieClip missing: " + (m_element.effect_mc == null ? "effect_mc " : "") + (m_element.noMatch_mc == null ? "noMatch_mc " : "") + (m_element.image_mc == null ? "image_mc " : "") + (m_element.matched_mc == null ? "matched_mc " : "") + (m_element.clicked_mc == null ? "clicked_mc " : "") + (m_element.back_mc == null ? "back_mc " : ""));
            }
            else
            {
               addWidget(this.m_matchEffect = new ZwFrame(m_element.effect_mc));
               addWidget(this.m_noMatch = new ZwFrame(m_element.noMatch_mc));
               addWidget(this.m_image = new ZwFrame(m_element.image_mc));
               addWidget(this.m_matched = new ZwFrame(m_element.matched_mc));
               addWidget(this.m_clicked = new ZwFrame(m_element.clicked_mc));
               addWidget(this.m_back = new ZwFrame(m_element.back_mc));
            }
         }
         else
         {
            ErrorManager.addError("PearUpCardSlot, constructor() error: parentWindow is not type PearUpWindow.");
         }
      }
      
      override public function release() : void
      {
         m_element.removeEventListener(MouseEvent.CLICK,this.onClick);
         m_element.removeEventListener(MouseEvent.ROLL_OVER,this.onRollOver);
         m_element.removeEventListener(MouseEvent.ROLL_OUT,this.onRollOut);
         this.m_parentWindow = null;
         this.m_matchEffect = null;
         this.m_noMatch = null;
         this.m_image = null;
         this.m_matched = null;
         this.m_clicked = null;
         this.m_back = null;
         super.release();
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         (this.m_image.element as MovieClip).gotoAndStop(data.cardIndex);
         this.m_image.visible = false;
         this.m_clicked.visible = false;
         this.m_matched.visible = false;
         this.m_back.visible = true;
         this.m_matchEffect.visible = false;
         this.m_noMatch.visible = false;
      }
      
      public function getCardId() : uint
      {
         return (this.m_image.element as MovieClip).currentFrame;
      }
      
      public function onRollOver(event:Event = null) : void
      {
         if(!this.isMatched())
         {
            TweenMax.to(this.m_element,0.2,{
               "scaleX":1.2,
               "scaleY":1.2,
               "ease":Elastic.easeOut
            });
         }
      }
      
      public function onRollOut(event:Event = null) : void
      {
         TweenMax.to(this.m_element,0.2,{
            "scaleX":1,
            "scaleY":1,
            "ease":Elastic.easeOut
         });
      }
      
      public function onClick(event:Event) : void
      {
         if(!this.m_parentWindow.gameplayInterupted() && !this.isMatched())
         {
            if(this.isFaceUp())
            {
               this.makeFaceDown();
               this.m_parentWindow.playSoundClickCard();
            }
            else
            {
               this.makeFaceUp();
               this.m_parentWindow.playSoundClickCard();
            }
         }
      }
      
      public function peekFaceDown() : Boolean
      {
         var result:Boolean = false;
         if(!this.isMatched())
         {
            this.makeFaceDown(false);
            this.onRollOut();
            result = true;
         }
         return result;
      }
      
      public function peekFaceUp() : Boolean
      {
         var result:Boolean = false;
         if(!this.isMatched())
         {
            this.onRollOver();
            this.makeFaceUp(false);
            result = true;
         }
         return result;
      }
      
      public function isFaceUp() : Boolean
      {
         return this.m_image.visible;
      }
      
      public function makeFaceDown(recordAsPlayerAction:Boolean = true) : void
      {
         this.hideSlot();
         if(recordAsPlayerAction)
         {
            this.m_parentWindow.removeClickedCard(this);
         }
      }
      
      public function makeFaceUp(recordAsPlayerAction:Boolean = true) : void
      {
         m_element.mouseEnabled = false;
         this.m_image.visible = true;
         TweenMax.from(m_element,2,{
            "scaleX":1,
            "scaleY":1,
            "ease":Elastic.easeOut
         });
         this.m_clicked.visible = true;
         this.m_back.visible = true;
         if(recordAsPlayerAction)
         {
            this.m_parentWindow.addClickedCard(this);
         }
      }
      
      public function match() : void
      {
         (this.m_matchEffect.element as MovieClip).gotoAndPlay(2);
         this.m_matched.visible = true;
      }
      
      public function isMatched() : Boolean
      {
         return this.m_matched.visible;
      }
      
      public function noMatch(animate:Boolean) : void
      {
         this.m_noMatch.visible = true;
         if(animate)
         {
            (this.m_noMatch.element as MovieClip).gotoAndPlay(2);
            TweenLite.delayedCall(1,this.hideSlot);
         }
         else
         {
            this.hideSlot();
         }
      }
      
      public function hideSlot() : void
      {
         m_element.mouseEnabled = true;
         this.m_clicked.visible = false;
         this.m_image.visible = false;
         this.m_back.visible = true;
         this.m_noMatch.visible = false;
      }
   }
}

