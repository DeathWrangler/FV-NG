package Widgets.Slots
{
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.FarmRunV5GameWindow;
   import Widgets.Windows.FarmWindow;
   import com.greensock.TweenLite;
   import com.greensock.TweenMax;
   import com.greensock.easing.Elastic;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.events.MouseEvent;
   import mx.utils.StringUtil;
   
   public class FarmRunV5GameCardSlot extends ZwSlotFrame
   {
      
      private static const ASSET_ROOT:String = "assets/dialogs/FarmRun2019_v2/{0}/{1}";
      
      private var m_data:Object;
      
      private var m_parentWindow:FarmRunV5GameWindow;
      
      private var m_matchEffect:ZwFrame = null;
      
      private var m_noMatch:ZwFrame = null;
      
      private var m_image:FarmIcon = null;
      
      private var m_matched:ZwFrame = null;
      
      private var m_clicked:ZwFrame = null;
      
      private var m_back:ZwFrame = null;
      
      public function FarmRunV5GameCardSlot(element:DisplayObject, parentWindow:FarmWindow)
      {
         super(element);
         this.m_parentWindow = parentWindow as FarmRunV5GameWindow;
         m_element.mouseEnabled = true;
         m_element.buttonMode = true;
         m_element.addEventListener(MouseEvent.CLICK,this.onClick);
         m_element.addEventListener(MouseEvent.ROLL_OVER,this.onRollOver);
         m_element.addEventListener(MouseEvent.ROLL_OUT,this.onRollOut);
         if(m_element.effect_mc != null)
         {
            addWidget(this.m_matchEffect = new ZwFrame(m_element.effect_mc));
         }
         if(m_element.noMatch_mc != null)
         {
            addWidget(this.m_noMatch = new ZwFrame(m_element.noMatch_mc));
         }
         if(m_element.image_mc != null)
         {
            addWidget(this.m_image = new FarmIcon(m_element.image_mc));
         }
         if(m_element.matched_mc != null)
         {
            addWidget(this.m_matched = new ZwFrame(m_element.matched_mc));
         }
         if(m_element.clicked_mc != null)
         {
            addWidget(this.m_clicked = new ZwFrame(m_element.clicked_mc));
         }
         if(m_element.back_mc != null)
         {
            addWidget(this.m_back = new ZwFrame(m_element.back_mc));
         }
      }
      
      override public function populate(data:Object) : void
      {
         super.populate(data);
         this.m_data = data;
         this.m_clicked.visible = false;
         this.m_matched.visible = false;
         this.m_back.visible = true;
         this.m_matchEffect.visible = false;
         this.m_noMatch.visible = false;
      }
      
      public function get slotId() : uint
      {
         return this.m_data.id;
      }
      
      private function get assetName() : String
      {
         return this.m_data.asset;
      }
      
      public function initSlot(onInitComplete:Function = null) : void
      {
         var imageURL:String = StringUtil.substitute(ASSET_ROOT,this.m_parentWindow.miniGameAssetsDir,this.assetName);
         this.m_image.loadIcon(Global.getAssetURL(imageURL),onInitComplete);
         this.m_image.fitIconInsideBounds(70,70);
         this.m_image.visible = false;
         if(this.isPaired())
         {
            this.remove();
         }
      }
      
      private function isPaired() : Boolean
      {
         return this.m_parentWindow.isSlotPaired(this.slotId);
      }
      
      private function onRollOver(event:Event = null) : void
      {
         if(!this.isPaired())
         {
            TweenMax.to(this.m_element,0.2,{
               "scaleX":1.2,
               "scaleY":1.2,
               "ease":Elastic.easeOut
            });
         }
      }
      
      private function onRollOut(event:Event = null) : void
      {
         TweenMax.to(this.m_element,0.2,{
            "scaleX":1,
            "scaleY":1,
            "ease":Elastic.easeOut
         });
      }
      
      private function isFaceUp() : Boolean
      {
         return this.m_image.visible;
      }
      
      private function makeFaceUp(recordAction:Boolean = true) : void
      {
         m_element.mouseEnabled = false;
         this.m_image.visible = true;
         TweenMax.from(m_element,1,{
            "scaleX":1,
            "scaleY":1,
            "ease":Elastic.easeOut
         });
         this.m_clicked.visible = true;
         this.m_back.visible = true;
         if(recordAction)
         {
            this.m_parentWindow.handleSlotClick(this);
         }
      }
      
      private function onClick(event:Event) : void
      {
         if(!this.isPaired() && !this.isFaceUp())
         {
            this.makeFaceUp();
         }
      }
      
      public function match() : void
      {
         if(this.m_matchEffect)
         {
            this.m_matchEffect.visible = true;
            (this.m_matchEffect.element as MovieClip).gotoAndPlay(2);
         }
         this.m_matched.visible = true;
         TweenLite.delayedCall(1,this.remove);
      }
      
      public function noMatch(animate:Boolean = true) : void
      {
         this.m_noMatch.visible = true;
         if(animate)
         {
            (this.m_noMatch.element as MovieClip).gotoAndPlay(2);
            TweenLite.delayedCall(1,this.hideImage);
         }
         else
         {
            this.hideImage();
         }
      }
      
      private function hideImage() : void
      {
         m_element.mouseEnabled = true;
         this.m_clicked.visible = false;
         this.m_image.visible = false;
         this.m_back.visible = true;
         this.m_noMatch.visible = false;
      }
      
      public function peek() : void
      {
         this.makeFaceUp(false);
      }
      
      public function hide() : void
      {
         this.hideImage();
         this.onRollOut();
      }
      
      private function remove() : void
      {
         m_element.visible = false;
         if(this.m_matchEffect)
         {
            this.m_matchEffect.visible = false;
         }
      }
   }
}

