package Widgets.Slots.Market
{
   import Classes.RewardCard;
   import Classes.util.ZLocUtils;
   import Managers.RewardCardsManager;
   import Widgets.Core.Base.ZwBaseWidget;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Frames.Market.MarketRewardCardsSlotFrame;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   
   public class MarketRewardCardsSlot extends ZwSlotFrame
   {
      
      private static const ICON_SIZE:int = 50;
      
      private var m_callbacks:Object;
      
      private var m_container:MarketRewardCardsSlotFrame;
      
      private var m_data:RewardCard;
      
      private var m_icon:FarmIcon;
      
      private var m_nameTextField:ZwTextField;
      
      private var m_countTextField:ZwTextField;
      
      private var m_creditsLeft:ZwTextField;
      
      private var m_backgroundTypes:Array;
      
      public function MarketRewardCardsSlot(element:DisplayObject, container:MarketRewardCardsSlotFrame, callbacks:Object)
      {
         this.m_container = container;
         this.m_callbacks = callbacks;
         super(element);
         this.m_icon = addWidget(new FarmIcon(m_element.icon_mc)) as FarmIcon;
         this.m_icon.setIconSize(ICON_SIZE,ICON_SIZE);
         addWidget(this.m_nameTextField = new ZwTextField(m_element.title_tf));
         addWidget(this.m_countTextField = new ZwTextField(m_element.number_tf));
         addWidget(this.m_creditsLeft = new ZwTextField(m_element.linkTitle_tf));
         this.m_backgroundTypes = new Array();
         var rewardCardTypes:Array = RewardCardsManager.getInstance().getRewardTypes();
         for(var i:int = 0; i < rewardCardTypes.length; i++)
         {
            if(m_element.hasOwnProperty(rewardCardTypes[i] + "Background"))
            {
               addWidget(this.m_backgroundTypes[rewardCardTypes[i].toString()] = new ZwBaseWidget(m_element[rewardCardTypes[i] + "Background"]));
            }
         }
      }
      
      public function get data() : RewardCard
      {
         return this.m_data;
      }
      
      override public function populate(data:Object) : void
      {
         var cardName:String = null;
         var owned:int = 0;
         var left:int = 0;
         var numberCount:String = null;
         var leftText:String = null;
         super.populate(data);
         this.m_data = data as RewardCard;
         if(this.m_data)
         {
            cardName = ZLocUtils.t("Dialogs","RewardCards_" + this.m_data.name);
            owned = this.m_data.freeCredits + this.m_data.purchaseCount;
            left = Math.max(0,this.m_data.credits - owned);
            numberCount = ZLocUtils.t("Dialogs","RewardCardsCount",{
               "owned":owned,
               "credits":this.m_data.credits
            });
            leftText = ZLocUtils.t("Dialogs","RewardCardsLeft",{"left":left});
            if(this.m_backgroundTypes[this.m_data.name] != null)
            {
               (this.m_backgroundTypes[this.m_data.name] as ZwBaseWidget).visible = true;
            }
            this.m_nameTextField.text = cardName;
            this.m_countTextField.text = numberCount;
            this.m_creditsLeft.text = leftText;
            this.m_nameTextField.visible = true;
            this.m_countTextField.visible = true;
            this.m_creditsLeft.visible = true;
         }
      }
   }
}

