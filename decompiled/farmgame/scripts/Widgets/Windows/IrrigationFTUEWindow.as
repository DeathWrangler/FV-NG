package Widgets.Windows
{
   import Classes.Constants.ZLocConstants;
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class IrrigationFTUEWindow extends FarmWindow
   {
      
      private static const ANIMATION_END:String = "animation_end";
      
      private var m_buttonLabelLookup:Array;
      
      private var m_animations:Array;
      
      private var m_currentAnimation:int = 0;
      
      private var m_itemPlaceOnAccept:String;
      
      private var m_okayBtn:FarmAnimatedTextButton;
      
      public function IrrigationFTUEWindow(windowAssetRelUrl:String, itemPlaceOnAccept:String)
      {
         this.m_itemPlaceOnAccept = itemPlaceOnAccept;
         super(windowAssetRelUrl);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.hasOwnProperty("main_mc"))
         {
            addWidget(new ZwFrame(m_window.main_mc));
            addWidget(this.m_okayBtn = new FarmAnimatedTextButton(m_window.main_mc.accept_bt,ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"Okay"),this.onClickOkay),false);
            this.setupAnimations();
            this.startAnimation();
         }
      }
      
      private function setupAnimations() : void
      {
         var animationWidget:ZwWidget = null;
         this.m_animations = [];
         var count:int = 1;
         this.m_buttonLabelLookup = [];
         while(m_window.main_mc.hasOwnProperty("animation" + count + "_mc"))
         {
            animationWidget = new ZwWidget(m_window.main_mc["animation" + count + "_mc"]);
            addWidget(animationWidget,false);
            this.m_animations.push(animationWidget);
            this.m_buttonLabelLookup.push(ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,"IrrigationFTUEWindow_" + this.m_itemPlaceOnAccept + "_slide" + count + "_btn"));
            count++;
         }
      }
      
      private function startAnimation() : void
      {
         var mc:MovieClip = null;
         this.m_okayBtn.visible = false;
         var currentAnimation:ZwWidget = this.m_animations[this.m_currentAnimation] as ZwWidget;
         if(currentAnimation)
         {
            currentAnimation.visible = true;
            mc = currentAnimation.element as MovieClip;
            if(mc)
            {
               mc.addEventListener(Event.ENTER_FRAME,this.onAnimationFrame);
               mc.play();
            }
         }
      }
      
      private function onAnimationFrame(event:Event) : void
      {
         var mc:MovieClip = null;
         var currentAnimation:ZwWidget = this.m_animations[this.m_currentAnimation] as ZwWidget;
         if(currentAnimation)
         {
            mc = currentAnimation.element as MovieClip;
            if(mc)
            {
               if(mc.currentLabel == ANIMATION_END)
               {
                  mc.removeEventListener(Event.ENTER_FRAME,this.onAnimationFrame);
                  this.m_okayBtn.text = this.m_buttonLabelLookup[this.m_currentAnimation];
                  this.m_okayBtn.visible = true;
               }
            }
         }
      }
      
      private function onClickOkay(event:Event) : void
      {
         var currentAnimation:ZwWidget = this.m_animations[this.m_currentAnimation] as ZwWidget;
         if(currentAnimation)
         {
            currentAnimation.visible = false;
            (m_window.main_mc as MovieClip).play();
            ++this.m_currentAnimation;
            this.startAnimation();
            if(this.m_animations.length <= this.m_currentAnimation + 1)
            {
               this.m_okayBtn.callback = this.onClickAccept;
            }
         }
      }
      
      private function onClickAccept(event:Event) : void
      {
         close();
         var inGiftbox:Boolean = Global.player.getGiftCountForItem(this.m_itemPlaceOnAccept) > 0;
         Global.world.enterForcePlaceMode(this.m_itemPlaceOnAccept,!inGiftbox,0,true,inGiftbox);
      }
      
      override protected function release() : void
      {
         this.m_okayBtn = null;
         super.release();
      }
   }
}

