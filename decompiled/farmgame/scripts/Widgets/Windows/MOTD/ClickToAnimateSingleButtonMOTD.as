package Widgets.Windows.MOTD
{
   import Classes.util.ZLocUtils;
   import Display.UI;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Windows.FVAnniversaryBirthdayGiftPopup;
   import flash.display.MovieClip;
   import flash.events.MouseEvent;
   
   public class ClickToAnimateSingleButtonMOTD extends GenericSingleButtonWidgetMOTD
   {
      
      private const COVER_MC:String = "cover_mc";
      
      private const CLAIM_BT:String = "generic_bt";
      
      private var m_coverMC:MovieClip;
      
      private var m_ClaimBtn:FarmAnimatedTextButton;
      
      private var m_onlyOnce:Boolean = false;
      
      public function ClickToAnimateSingleButtonMOTD(displayParams:Object = null)
      {
         super(displayParams);
      }
      
      override protected function postLoadComplete() : void
      {
         super.postLoadComplete();
         if(m_window.mainWindow.hasOwnProperty(this.COVER_MC))
         {
            this.m_coverMC = m_window.mainWindow[this.COVER_MC];
            if(this.m_coverMC)
            {
               this.m_coverMC.gotoAndStop(1);
               this.m_coverMC.addEventListener(MouseEvent.CLICK,this.onMCClick);
               if(this.m_coverMC.hasOwnProperty(this.CLAIM_BT))
               {
                  this.m_ClaimBtn = addWidget(new FarmAnimatedTextButton(this.m_coverMC[this.CLAIM_BT],ZLocUtils.t_pk(m_currentMOTD["buttonText"]),this.onAccept)) as FarmAnimatedTextButton;
               }
            }
         }
         (m_window.mainWindow as MovieClip).gotoAndStop(1);
      }
      
      private function onMCClick(event:MouseEvent) : void
      {
         if(Boolean(this.m_coverMC) && !this.m_onlyOnce)
         {
            (m_window.mainWindow as MovieClip).play();
            this.m_coverMC.play();
            this.m_coverMC.removeEventListener(MouseEvent.CLICK,this.onMCClick);
            this.m_onlyOnce = true;
         }
      }
      
      override protected function onAccept(event:MouseEvent) : void
      {
         super.onAccept(event);
         UI.displayPopup(new FVAnniversaryBirthdayGiftPopup(),false);
      }
   }
}

