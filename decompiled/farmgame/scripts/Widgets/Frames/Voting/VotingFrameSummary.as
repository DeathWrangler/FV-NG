package Widgets.Frames.Voting
{
   import Classes.FeatureComponents.VotingComponent;
   import Classes.ZItem.DeprecatorSettings;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.TemplateUIUtility;
   import Managers.VotingDataManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class VotingFrameSummary extends ZwFrame
   {
      
      private var m_featureName:String;
      
      private var m_replayButton:FarmAnimatedTextButton;
      
      private var m_summaryFrame:ZwFrame = null;
      
      private var m_prizeItemCallback:Function = null;
      
      private var m_replayCallback:Function = null;
      
      private var m_deprecator:DeprecatorSettings;
      
      public function VotingFrameSummary(element:DisplayObject, featureName:String, prizeItemCallback:Function, replayCallback:Function, textColor:String = null)
      {
         var headerTextField:ZwTextField = null;
         super(element);
         this.m_featureName = featureName;
         this.m_prizeItemCallback = prizeItemCallback;
         this.m_replayCallback = replayCallback;
         if(m_element.hasOwnProperty("header_tf") && m_element.header_tf != null)
         {
            headerTextField = addWidget(new ZwTextField(m_element.header_tf,ZLocUtils.t("Voting","HeaderText"))) as ZwTextField;
            if(Boolean(headerTextField) && textColor != null)
            {
               TemplateUIUtility.applyTextColor(headerTextField,TemplateUIUtility.VOTING,textColor);
            }
         }
         this.update();
      }
      
      public function update() : void
      {
         var sum:int = 0;
         var PKSubtitle:String = null;
         var PKQuestion:String = null;
         var PKDescription:String = null;
         var prizeItem:Object = null;
         var prizeItemIdentifier:String = null;
         var item:FarmItem = null;
         var voteResults:Array = VotingDataManager.getInstance().getDataObject(this.m_featureName).voteResults;
         for(var i:int = 0; i < voteResults.length; i++)
         {
            if(voteResults[i] > -1)
            {
               sum += parseInt(voteResults[i]);
            }
         }
         if(this.element.hasOwnProperty("summary_mc") && Boolean(this.element.summary_mc))
         {
            this.m_summaryFrame = new ZwFrame(m_element.summary_mc);
            addWidget(this.m_summaryFrame);
            if(Boolean(this.element.summary_mc.hasOwnProperty("header0_tf")) && this.element.summary_mc.header0_tf != null)
            {
               PKSubtitle = VotingComponent.getLocalizedKey(this.m_featureName,"SummaryCompleted");
               this.m_summaryFrame.addWidget(new ZwTextField(this.element.summary_mc.header0_tf,ZLocUtils.t_pk(PKSubtitle)));
            }
            if(Boolean(this.element.summary_mc.hasOwnProperty("header1_tf")) && this.element.summary_mc.header1_tf != null)
            {
               PKQuestion = VotingComponent.getLocalizedKey(this.m_featureName,"OutcomeTitle_" + sum);
               this.m_summaryFrame.addWidget(new ZwTextField(this.element.summary_mc.header1_tf,ZLocUtils.t_pk(PKQuestion)));
            }
            if(Boolean(this.element.summary_mc.hasOwnProperty("header2_tf")) && this.element.summary_mc.header2_tf != null)
            {
               PKDescription = VotingComponent.getLocalizedKey(this.m_featureName,"OutcomeBody_" + sum);
               this.m_summaryFrame.addWidget(new ZwTextField(this.element.summary_mc.header2_tf,ZLocUtils.t_pk(PKDescription)));
            }
            if(Boolean(this.element.summary_mc.hasOwnProperty("replay_bt")) && Boolean(this.element.summary_mc.replay_bt != null) && !this.isFeatureDeprecated())
            {
               this.m_replayButton = new FarmAnimatedTextButton(this.element.summary_mc.replay_bt);
               this.m_replayButton.text = ZLocUtils.tk_pk_asTitle("Voting:Replay");
               this.m_replayButton.callback = this.replayCallback;
               addWidget(this.m_replayButton);
            }
            if(Boolean(m_element.summary_mc.hasOwnProperty("voteBack_mc")) && m_element.summary_mc.voteBack_mc != null)
            {
               addWidget(new ZwFrame(m_element.summary_mc.voteBack_mc));
            }
            if(this.m_prizeItemCallback != null)
            {
               prizeItem = this.m_prizeItemCallback(sum);
               if(prizeItem)
               {
                  prizeItemIdentifier = prizeItem.code;
                  item = Global.farmGameSettingsManager.getFarmItemByCode(prizeItemIdentifier);
                  if(item != null && Boolean(item.iconUrl))
                  {
                     if(Boolean(this.element.summary_mc.hasOwnProperty("item_mc")) && this.element.summary_mc.item_mc != null)
                     {
                        this.m_summaryFrame.addWidget(new FarmIcon(m_element.summary_mc.item_mc,item.iconUrl));
                     }
                  }
               }
            }
         }
      }
      
      private function replayCallback(event:MouseEvent) : void
      {
         if(this.m_replayCallback != null)
         {
            this.m_replayCallback(event);
         }
      }
      
      private function isFeatureDeprecated() : Boolean
      {
         if(this.m_deprecator == null)
         {
            this.m_deprecator = Global.farmGameSettingsManager.getDeprecatorSettings(this.m_featureName);
         }
         return Boolean(this.m_deprecator) && this.m_deprecator.checkPrereqs();
      }
   }
}

