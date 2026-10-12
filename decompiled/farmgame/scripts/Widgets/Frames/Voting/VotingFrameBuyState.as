package Widgets.Frames.Voting
{
   import Classes.FeatureComponents.VotingComponent;
   import Classes.util.ZLocUtils;
   import Managers.TemplateUIUtility;
   import Managers.VotingDataManager;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObject;
   
   public class VotingFrameBuyState extends ZwFrame
   {
      
      private var m_creditsFeatureName:String;
      
      private var m_buttonCallbacks:Object;
      
      private var m_arrPrizeSlot:Array;
      
      private var m_arrAllVoteItems:Array;
      
      private var m_arrVoteTextField:Array;
      
      private var m_askButton:FarmAnimatedTextButton;
      
      private var m_askOrNextToolTip:FarmTextTooltip = null;
      
      protected var m_questionTextField:ZwTextField = null;
      
      private var m_completeFrame:ZwFrame;
      
      private var m_arrPrizeCanBeBought:Array;
      
      private var m_bBuyMode:Boolean;
      
      private var m_questionBackPanel:ZwFrame;
      
      private var m_textColor:String = null;
      
      public function VotingFrameBuyState(element:DisplayObject, creditsFeatureName:String, buttonCallbacks:Object, arrVotingUIDs:Array, arrAllVoteItems:Array, stage:int, bBuyMode:Boolean, textColor:String = null)
      {
         var headerTextField:ZwTextField = null;
         super(element);
         this.m_creditsFeatureName = creditsFeatureName;
         this.m_buttonCallbacks = buttonCallbacks;
         this.m_bBuyMode = bBuyMode;
         this.m_arrAllVoteItems = arrAllVoteItems;
         this.m_arrPrizeCanBeBought = new Array();
         for(var iParty:int = 0; iParty < arrVotingUIDs.length; iParty++)
         {
            this.m_arrPrizeCanBeBought.push(true);
         }
         this.m_textColor = textColor;
         if(Boolean(m_element) && Boolean(m_element["header_tf"]))
         {
            headerTextField = addWidget(new ZwTextField(m_element.header_tf,ZLocUtils.t("Voting","HeaderText"))) as ZwTextField;
            if(this.m_textColor != null)
            {
               TemplateUIUtility.applyTextColor(headerTextField,TemplateUIUtility.VOTING,this.m_textColor);
            }
         }
         this.update(arrVotingUIDs,stage,bBuyMode);
      }
      
      private function removeUpdateWidgets() : void
      {
         var iPartyPrize:int = 0;
         if(this.m_arrPrizeSlot != null)
         {
            for(iPartyPrize = 0; iPartyPrize < this.m_arrPrizeSlot.length; iPartyPrize++)
            {
               if(this.m_arrPrizeSlot[iPartyPrize] != null)
               {
                  removeWidget(this.m_arrPrizeSlot[iPartyPrize]);
               }
            }
         }
         if(this.m_questionTextField != null)
         {
            removeWidget(this.m_questionTextField);
            this.m_questionTextField = null;
         }
         if(this.m_completeFrame != null)
         {
            removeWidget(this.m_completeFrame);
            this.m_completeFrame = null;
         }
         if(this.m_askButton != null)
         {
            removeWidget(this.m_askButton);
            this.m_askButton = null;
         }
         if(this.m_questionBackPanel != null)
         {
            removeWidget(this.m_questionBackPanel);
            this.m_questionBackPanel = null;
         }
      }
      
      private function createQuestionWidget(stage:int) : void
      {
         var PKQuestion:String = VotingComponent.getLocalizedKey(this.m_creditsFeatureName,"CrewVoting_" + stage + "_Text");
         if(m_element.hasOwnProperty("question_mc") && m_element.question_mc.question_tf != null)
         {
            this.m_questionTextField = new ZwTextField(m_element.question_mc.question_tf,ZLocUtils.t_pk(PKQuestion));
            addWidget(this.m_questionTextField);
            if(Boolean(this.m_questionTextField) && this.m_textColor != null)
            {
               TemplateUIUtility.applyTextColor(this.m_questionTextField,TemplateUIUtility.VOTING,this.m_textColor);
            }
            m_element.question_mc.visible = true;
         }
         if(m_element.hasOwnProperty("voteBack_mc") && m_element.voteBack_mc != null)
         {
            this.m_questionBackPanel = new ZwFrame(m_element.voteBack_mc);
            addWidget(this.m_questionBackPanel);
         }
      }
      
      public function createAskButton() : void
      {
         if(this.element.hasOwnProperty("ask_bt") && this.element.ask_bt != null)
         {
            if(this.m_askButton == null)
            {
               this.m_askButton = new FarmAnimatedTextButton(this.element.ask_bt);
               addWidget(this.m_askButton);
               this.m_askOrNextToolTip = new FarmTextTooltip("");
               this.m_askButton.attachTooltip(this.m_askOrNextToolTip);
            }
            this.m_askButton.text = ZLocUtils.tk_pk_asTitle("Dialogs:AskForVotes");
            this.m_askButton.applyGrayOut = true;
         }
      }
      
      private function createOutcomeWidget(voteIndex:int, stage:int) : void
      {
         var outcomeStr:String = null;
         var PKOutcome:String = null;
         var outcomeText:String = null;
         var elementName:String = "vote" + voteIndex.toString() + "_tf";
         if(m_element.hasOwnProperty(elementName) && m_element[elementName] != null)
         {
            outcomeStr = "Vote_" + stage + "_" + voteIndex + "_Text";
            PKOutcome = VotingComponent.getLocalizedKey(this.m_creditsFeatureName,outcomeStr);
            outcomeText = ZLocUtils.t_pk(PKOutcome);
            this.m_arrVoteTextField[voteIndex] = new ZwTextField(m_element[elementName],outcomeText);
            addWidget(this.m_arrVoteTextField[voteIndex]);
            if(Boolean(this.m_arrVoteTextField) && Boolean(this.m_arrVoteTextField[voteIndex]) && this.m_textColor != null)
            {
               TemplateUIUtility.applyTextColor(this.m_arrVoteTextField[voteIndex],TemplateUIUtility.VOTING,this.m_textColor);
            }
         }
      }
      
      protected function getVoteItems(stage:int) : Array
      {
         var voteItem:Object = null;
         var voteItems:Array = new Array();
         for each(voteItem in this.m_arrAllVoteItems)
         {
            if(voteItem.index == stage)
            {
               voteItems.push(voteItem);
            }
         }
         voteItems.sortOn("voteIndex",Array.NUMERIC);
         return voteItems;
      }
      
      public function update(arrVotingUIDs:Array, stage:int, bBuyMode:Boolean) : void
      {
         var iVoteIndex:int = 0;
         var item:Object = null;
         var buyCost:Number = NaN;
         this.removeUpdateWidgets();
         this.m_bBuyMode = bBuyMode;
         var voteItems:Array = this.getVoteItems(stage);
         this.m_arrPrizeSlot = new Array();
         this.m_arrVoteTextField = new Array();
         var bHasShownCrewHeader:Boolean = false;
         for(iVoteIndex = 0; iVoteIndex < arrVotingUIDs.length; iVoteIndex++)
         {
            item = voteItems[iVoteIndex];
            buyCost = bBuyMode ? Number(item.buyCost) : 0;
            this.m_arrPrizeSlot[iVoteIndex] = new VotingBuyPrize(m_element["slot_" + iVoteIndex.toString() + "_mc"],item.name,iVoteIndex,buyCost,item.icon,this.m_buttonCallbacks,this.m_textColor);
            addWidget(this.m_arrPrizeSlot[iVoteIndex]);
            if(bBuyMode)
            {
               this.createOutcomeWidget(iVoteIndex,stage);
            }
         }
         if(bBuyMode)
         {
            this.createQuestionWidget(stage);
         }
         else
         {
            this.createAskButton();
         }
         var voteIndex:int = VotingDataManager.getInstance().getVoteResults(this.m_creditsFeatureName,stage);
         if(voteIndex >= 0 && Boolean(this.m_arrPrizeSlot[voteIndex]))
         {
            this.m_arrPrizeSlot[voteIndex].showCheckMark();
         }
      }
   }
}

