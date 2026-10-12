package Widgets.Frames.SlotMachine
{
   import Classes.FeatureBuilding;
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import flash.display.DisplayObject;
   import flash.events.MouseEvent;
   
   public class SlotMachineProgressFrame extends ZwFrame
   {
      
      private var m_building:FeatureBuilding;
      
      private var m_askButton:FarmAnimatedTextButton;
      
      private var m_buyButton:FarmAnimatedTextButton;
      
      private var m_throwButton:FarmAnimatedTextButton;
      
      private var m_tokenCountFrame:SlotMachineTokenCountFrame;
      
      private var m_bonusEmptyFrame:SlotMachineEmptyBonusFrame;
      
      private var m_bonusFullFrame:SlotMachineFullBonusFrame;
      
      public function SlotMachineProgressFrame(element:DisplayObject, building:FeatureBuilding)
      {
         super(element);
         this.m_building = building;
         var buildingName:String = this.m_building.getItem().name;
         this.m_askButton = addWidget(new FarmAnimatedTextButton(m_element.ask_bt,ZLocUtils.t("Dialogs",buildingName + "_AskButton"),this.m_building.slotmachine.onAskTokens),this.m_building.slotmachine.isEnabled) as FarmAnimatedTextButton;
         this.m_buyButton = addWidget(new FarmAnimatedTextButton(m_element.buy_bt,ZLocUtils.t("Dialogs",buildingName + "_BuyButton"),this.m_building.slotmachine.onBuyTokens)) as FarmAnimatedTextButton;
         this.m_throwButton = addWidget(new FarmAnimatedTextButton(m_element.throw_bt,ZLocUtils.t("Dialogs",buildingName + "_ThrowButton"),this.onUseTokens)) as FarmAnimatedTextButton;
         this.setButtonState(false,false);
         this.m_tokenCountFrame = addWidget(new SlotMachineTokenCountFrame(m_element.pennyCount_mc,this.m_building)) as SlotMachineTokenCountFrame;
         this.m_bonusEmptyFrame = addWidget(new SlotMachineEmptyBonusFrame(m_element.BonusEmptyFrame_mc)) as SlotMachineEmptyBonusFrame;
         this.m_bonusFullFrame = addWidget(new SlotMachineFullBonusFrame(m_element.BonusFullFrame_mc,this.m_building),false) as SlotMachineFullBonusFrame;
      }
      
      public function onUseTokens(event:MouseEvent) : void
      {
         this.m_throwButton.enabled = false;
         this.m_building.slotmachine.onUseTokens(event);
      }
      
      public function update(isPennyThrowAnimationPlaying:Boolean, isRewardFoundAnimationPlaying:Boolean) : void
      {
         this.m_tokenCountFrame.update();
         this.m_bonusFullFrame.update();
         this.setButtonState(isPennyThrowAnimationPlaying,isRewardFoundAnimationPlaying);
         this.setBonusFrameState();
      }
      
      public function setButtonState(isPennyThrowAnimationPlaying:Boolean, isRewardFoundAnimationPlaying:Boolean) : void
      {
         if(this.m_building.slotmachine.tokenCount > 0)
         {
            this.m_askButton.visible = false;
            this.m_buyButton.visible = false;
            this.m_throwButton.visible = true;
            this.m_throwButton.enabled = true;
            if(this.m_building.slotmachine.canCompleteCurrentLevel || isPennyThrowAnimationPlaying || isRewardFoundAnimationPlaying)
            {
               this.m_throwButton.enabled = false;
            }
         }
         else
         {
            this.m_askButton.visible = true;
            this.m_askButton.enabled = this.m_building.slotmachine.isEnabled;
            this.m_buyButton.visible = true;
            this.m_buyButton.enabled = this.m_building.slotmachine.isEnabled;
            this.m_throwButton.visible = false;
         }
      }
      
      private function setBonusFrameState() : void
      {
         var buildingData:Object = this.m_building.slotmachine.lastTransactionResult;
         if(buildingData)
         {
            if(buildingData.hasOwnProperty("lootItemName") && Boolean(buildingData.lootItemName))
            {
               this.m_bonusFullFrame.visible = true;
               this.m_bonusEmptyFrame.visible = false;
            }
            else
            {
               this.m_bonusEmptyFrame.visible = true;
               this.m_bonusFullFrame.visible = false;
            }
         }
      }
   }
}

