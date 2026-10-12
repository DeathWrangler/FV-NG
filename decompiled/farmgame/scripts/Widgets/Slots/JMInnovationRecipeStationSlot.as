package Widgets.Slots
{
   import Classes.Constants.ZLocConstants;
   import Classes.ZItem.FarmItem;
   import Classes.util.FarmGameUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.HUD.HUD;
   import Display.UI;
   import Events.GenericPopupEvent;
   import Managers.JMInnovationManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Tooltips.FarmTextTooltip;
   import Widgets.Windows.FarmWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   
   public class JMInnovationRecipeStationSlot extends ZwSlotFrame
   {
      
      private var m_featureName:String;
      
      private var m_data:Object;
      
      private var m_isSameBuffActive:Boolean;
      
      private var m_isOtherBuffActive:Boolean;
      
      private const BUFFCOUNT_MC:String = "buffCount_mc";
      
      private const BUFFCOUNT_TF:String = "buffCount_tf";
      
      private const TIMER_TF:String = "timer_tf";
      
      private const USE_BT:String = "use_bt";
      
      private const USE_EFFECT:String = "use_effect";
      
      private const ICON_MC:String = "icon_mc";
      
      private var m_useEffect:MovieClip;
      
      private var m_buffCountMC:MovieClip;
      
      private var m_buffCountTf:ZwTextField;
      
      private var m_iconMc:ZwFrame;
      
      private var m_useButton:FarmAnimatedTextButton;
      
      private const TEXT_BUFF_HOVER:String = "_buff_locked_hover";
      
      private const TEXT_USE_CONFIRMATION:String = "_use_action_confirm";
      
      public function JMInnovationRecipeStationSlot(featureName:String, element:DisplayObject, window:FarmWindow)
      {
         this.m_featureName = featureName;
         super(element);
         if(m_element.hasOwnProperty(this.USE_EFFECT))
         {
            this.m_useEffect = m_element[this.USE_EFFECT] as MovieClip;
            this.disableUseEffect();
         }
         if(m_element.hasOwnProperty(this.BUFFCOUNT_MC))
         {
            this.m_buffCountMC = m_element[this.BUFFCOUNT_MC] as MovieClip;
            if(m_element[this.BUFFCOUNT_MC].hasOwnProperty(this.BUFFCOUNT_TF))
            {
               this.m_buffCountTf = new ZwTextField(m_element[this.BUFFCOUNT_MC][this.BUFFCOUNT_TF]);
            }
         }
         if(m_element.hasOwnProperty(this.USE_BT))
         {
            addWidget(this.m_useButton = new FarmAnimatedTextButton(m_element[this.USE_BT],"Use",this.onClickUseButton));
         }
         if(m_element.hasOwnProperty(this.ICON_MC))
         {
            addWidget(this.m_iconMc = new ZwFrame(m_element[this.ICON_MC]));
         }
      }
      
      override public function populate(data:Object) : void
      {
         var infoTooltip:FarmTextTooltip = null;
         var buffCount:int = 0;
         var timeLeft:Number = NaN;
         var attachedToolTip:FarmTextTooltip = null;
         super.populate(data);
         this.m_data = data;
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_data.code);
         infoTooltip = new FarmTextTooltip(item.friendlyTitle);
         buffCount = this.manager.getBuffCountForSlot(this.m_data.slotIndex);
         this.m_isSameBuffActive = this.manager.getActiveBuff() == this.m_data.code;
         this.m_isOtherBuffActive = this.manager.getActiveBuff() != null;
         if(buffCount < 0)
         {
            (m_element as MovieClip).gotoAndStop(2);
            infoTooltip.setText(ZLocUtils.t(ZLocConstants.DIALOG_UTIL_PKG,this.m_featureName + this.TEXT_BUFF_HOVER));
         }
         else
         {
            (m_element as MovieClip).gotoAndStop(1);
            if(Boolean(this.m_buffCountMC) && Boolean(this.m_buffCountTf))
            {
               this.m_buffCountMC.visible = true;
               this.m_buffCountTf.visible = true;
               this.m_buffCountTf.text = buffCount + "";
            }
            if(Boolean(this.m_useButton) && buffCount > 0)
            {
               this.m_useButton.visible = true;
               if(this.m_isOtherBuffActive)
               {
                  this.m_useButton.callback = null;
                  FarmGameUtil.disableButtonAndShowTooltip(this.m_useButton,"Another buff is already active!");
               }
            }
         }
         if(m_element.hasOwnProperty(this.TIMER_TF))
         {
            if(this.m_isSameBuffActive)
            {
               this.m_useButton.visible = false;
               m_element[this.TIMER_TF].visible = true;
               timeLeft = this.manager.getTimeLeftForActiveBuff();
               if(timeLeft > 0)
               {
                  m_element[this.TIMER_TF].text = "Active for " + HUD.getformattedTimeLeft(timeLeft);
               }
            }
         }
         if(this.m_iconMc)
         {
            this.m_iconMc.visible = true;
            attachedToolTip = this.m_iconMc.tooltip as FarmTextTooltip;
            if(attachedToolTip == null || attachedToolTip.getText() != infoTooltip.getText())
            {
               if(attachedToolTip)
               {
                  this.m_iconMc.detachTooltip();
               }
               this.m_iconMc.attachTooltip(infoTooltip);
            }
         }
      }
      
      private function get manager() : JMInnovationManager
      {
         return JMInnovationManager.getInstance(this.m_featureName);
      }
      
      private function onClickUseButton(event:Event) : void
      {
         var popup:GenericPopup = null;
         var confirmationText:String = ZLocUtils.t("Dialogs",this.m_featureName + this.TEXT_USE_CONFIRMATION);
         var item:FarmItem = Global.farmGameSettingsManager.getFarmItemByCode(this.m_data.code);
         UI.displayPopup(popup = new GenericPopup(confirmationText,GenericPopup.TYPE_OK,this.beginUse,this.manager.useConfirmWindow,"",false,false,true),false);
         popup.setAcceptTextName("ApplyButtonText");
         popup.iconUrl = item.iconUrl;
      }
      
      private function beginUse(event:GenericPopupEvent) : void
      {
         if(event.button == GenericPopup.OK)
         {
            this.manager.useBuff(this.m_data.code);
            this.enableUseEffect();
            m_element[this.TIMER_TF].visible = true;
            this.m_useButton.visible = false;
         }
      }
      
      private function disableUseEffect() : void
      {
         if(this.m_useEffect)
         {
            this.m_useEffect.stop();
            this.m_useEffect.visible = false;
         }
      }
      
      private function enableUseEffect() : void
      {
         if(this.m_useEffect)
         {
            this.m_useEffect.play();
            this.m_useEffect.visible = true;
         }
      }
   }
}

