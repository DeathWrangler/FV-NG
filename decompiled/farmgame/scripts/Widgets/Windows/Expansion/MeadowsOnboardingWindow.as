package Widgets.Windows.Expansion
{
   import Classes.Constants.Experiments;
   import Classes.Constants.StatsTrackingConstants;
   import Classes.ZItem.ExpansionAccess;
   import Classes.util.MovieClipUtils;
   import Classes.util.ObjectUtil;
   import Classes.util.ZLocUtils;
   import Display.GenericPopup;
   import Display.UI;
   import Engine.Managers.StatsManager;
   import Events.ExpansionAccessEvent;
   import Events.GenericPopupEvent;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Buttons.FarmButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.events.Event;
   
   public class MeadowsOnboardingWindow extends ExpansionOnboardingWindow
   {
      
      private static const MEADOWS_COINS_COST:String = "200 Million";
      
      private static const MEADOWS_FICTION_ON:String = "xmw_meadow_fiction_on";
      
      private static const MEADOWS_FICTION_OFF:String = "xmw_meadow_fiction_off";
      
      private static const MEADOW_STATS_COUNTER:String = "meadow";
      
      private static const HOME_STATS_COUNTER:String = "home";
      
      private static const CONFIRMATION_CASH_STATS_COUNTER:String = "confirmation_cash";
      
      private static const CONFIRMATION_COINS_STATS_COUNTER:String = "confirmation_coins";
      
      private static const VIEW_STATS_COUNTER:String = "view";
      
      private static const CANCEL_STATS_COUNTER:String = "cancel";
      
      private var m_fiction:Boolean;
      
      private var m_selectedOption:String;
      
      public function MeadowsOnboardingWindow(assetPath:String, acceptText:String = "", acceptCallback:Function = null, cancelCallback:Function = null, accessConfig:ExpansionAccess = null)
      {
         super(assetPath,acceptText,acceptCallback,cancelCallback,accessConfig);
         if(Global.experimentManager.getExperimentVariant(Experiments.EXPERIMENT_MEADOWS_FICTION) == Experiments.VARIANT_MEADOWS_FICTION_ON)
         {
            this.m_fiction = true;
         }
         else
         {
            this.m_fiction = false;
         }
      }
      
      override protected function postLoadComplete() : void
      {
         var cost_tf:ZwTextField = null;
         var cost2_tf:ZwTextField = null;
         var coincost_tf:ZwTextField = null;
         var generic_0_tf:ZwTextField = null;
         var generic_1_tf:ZwTextField = null;
         if(m_window.play_mc)
         {
            addWidget(new ZwFrame(m_window.play_mc));
            if(ObjectUtil.pathExists(m_window,["play_mc","generic_mc"]))
            {
               if(ObjectUtil.pathExists(m_window,["play_mc","generic_mc","generic_bt"]))
               {
                  addWidget(new FarmAnimatedTextButton(m_window.play_mc.generic_mc.generic_bt,super.m_acceptText,this.promptUserCash199));
               }
               if(ObjectUtil.pathExists(m_window,["play_mc","generic_mc","generic2_bt"]))
               {
                  addWidget(new FarmAnimatedTextButton(m_window.play_mc.generic_mc.generic2_bt,super.m_acceptText,this.promptUserCash60));
               }
               if(ObjectUtil.pathExists(m_window,["play_mc","generic_mc","buy_bt"]))
               {
                  addWidget(new FarmAnimatedTextButton(m_window.play_mc.generic_mc.buy_bt,super.m_acceptText,this.promptUserCoins));
               }
               if(ObjectUtil.pathExists(m_window,["play_mc","generic_mc","cost_tf"]))
               {
                  cost_tf = new ZwTextField(m_window.play_mc.generic_mc.cost_tf);
                  addWidget(cost_tf);
                  cost_tf.text = m_accessConfig.getOptionCost("cash199").toString();
               }
               if(ObjectUtil.pathExists(m_window,["play_mc","generic2_mc","cost2_tf"]))
               {
                  cost2_tf = new ZwTextField(m_window.play_mc.generic2_mc.cost2_tf);
                  addWidget(cost2_tf);
                  cost2_tf.text = m_accessConfig.getOptionCost("cash60").toString();
               }
               if(ObjectUtil.pathExists(m_window,["play_mc","generic_mc","coincost_tf"]))
               {
                  coincost_tf = new ZwTextField(m_window.play_mc.generic_mc.coincost_tf);
                  addWidget(coincost_tf);
                  coincost_tf.text = MEADOWS_COINS_COST;
               }
               if(this.m_fiction)
               {
                  if(ObjectUtil.pathExists(m_window,["play_mc","generic_mc","generic_0_mc"]))
                  {
                     addWidget(new ZwFrame(m_window.play_mc.generic_mc.generic_0_mc));
                     generic_0_tf = new ZwTextField(m_window.play_mc.generic_mc.generic_0_mc.generic_0_tf);
                     addWidget(generic_0_tf);
                     generic_0_tf.text = ZLocUtils.t("Dialogs",MEADOWS_FICTION_ON + "_dialog");
                  }
               }
               else if(ObjectUtil.pathExists(m_window,["play_mc","generic_mc","generic_1_mc"]))
               {
                  addWidget(new ZwFrame(m_window.play_mc.generic_mc.generic_1_mc));
                  m_window.play_mc.generic_mc.generic_0_mc.visible = false;
                  generic_1_tf = new ZwTextField(m_window.play_mc.generic_mc.generic_1_mc.generic_1_tf);
                  addWidget(generic_1_tf);
                  generic_1_tf.text = ZLocUtils.t("Dialogs",MEADOWS_FICTION_OFF + "_dialog");
               }
            }
            if(m_window.play_mc.close_bt)
            {
               addWidget(new FarmButton(m_window.play_mc.close_bt,cancelPrompt));
            }
            MovieClipUtils.recursivePlay(m_window.play_mc);
         }
         initAutoCenterTimer();
      }
      
      private function promptUserCash199(event:Event) : void
      {
         m_window.visible = false;
         this.m_selectedOption = "cash199";
         StatsManager.count(StatsTrackingConstants.DIALOG_STATS_COUNTER,MEADOW_STATS_COUNTER,CONFIRMATION_CASH_STATS_COUNTER,StatsTrackingConstants.STATS_APPEARED,VIEW_STATS_COUNTER,HOME_STATS_COUNTER);
         UI.displayMessage(ZLocUtils.t("Dialogs","xmw_confirmation_cash",{"cashQuantity":m_accessConfig.getOptionCost(this.m_selectedOption).toString()}),GenericPopup.TYPE_YESNO,this.onConfirmBuy,"",true);
      }
      
      private function promptUserCash60(event:Event) : void
      {
         m_window.visible = false;
         this.m_selectedOption = "cash60";
         StatsManager.count(StatsTrackingConstants.DIALOG_STATS_COUNTER,MEADOW_STATS_COUNTER,CONFIRMATION_CASH_STATS_COUNTER,StatsTrackingConstants.STATS_APPEARED,VIEW_STATS_COUNTER,HOME_STATS_COUNTER);
         UI.displayMessage(ZLocUtils.t("Dialogs","xmw_confirmation_cash",{"cashQuantity":m_accessConfig.getOptionCost(this.m_selectedOption).toString()}),GenericPopup.TYPE_YESNO,this.onConfirmBuy,"",true);
      }
      
      private function promptUserCoins(event:Event) : void
      {
         m_window.visible = false;
         this.m_selectedOption = "coins200000000";
         StatsManager.count(StatsTrackingConstants.DIALOG_STATS_COUNTER,MEADOW_STATS_COUNTER,CONFIRMATION_COINS_STATS_COUNTER,StatsTrackingConstants.STATS_APPEARED,VIEW_STATS_COUNTER,HOME_STATS_COUNTER);
         UI.displayMessage(ZLocUtils.t("Dialogs","xmw_confirmation_coins",{"coinsQuantity":MEADOWS_COINS_COST}),GenericPopup.TYPE_YESNO,this.onConfirmBuy,"",true);
      }
      
      protected function onConfirmBuy(event:GenericPopupEvent) : void
      {
         var accessEvent:ExpansionAccessEvent = null;
         var accepted:Boolean = event.button == GenericPopup.YES;
         var statsCurrencyText:String = m_accessConfig.getOptionCurrency(this.m_selectedOption) == "cash" ? CONFIRMATION_CASH_STATS_COUNTER : CONFIRMATION_COINS_STATS_COUNTER;
         var statsAcceptText:String = accepted == true ? StatsTrackingConstants.DIALOG_STATS_ACCEPT_PHYLUM : CANCEL_STATS_COUNTER;
         StatsManager.count(StatsTrackingConstants.DIALOG_STATS_COUNTER,MEADOW_STATS_COUNTER,statsCurrencyText,StatsTrackingConstants.STATS_APPEARED,statsAcceptText,HOME_STATS_COUNTER);
         if(accepted)
         {
            accessEvent = new ExpansionAccessEvent(Event.COMPLETE,this.m_selectedOption);
            acceptPrompt(accessEvent);
         }
         else
         {
            m_window.visible = true;
         }
      }
   }
}

