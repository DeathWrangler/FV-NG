package Widgets.Slots
{
   import Classes.Minigames.RedeemablesFeatureData;
   import Display.UI;
   import Engine.Managers.ErrorManager;
   import Engine.Managers.TransactionManager;
   import Transactions.TGenericTransaction;
   import Widgets.Buttons.FarmAnimatedButton;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.Frames.ZwSlotFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Windows.FarmWindow;
   import Widgets.Windows.Minigame.MinigameWindow;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   import flash.events.Event;
   import flash.geom.Point;
   
   public class RedeemableSlot extends ZwSlotFrame
   {
      
      private var m_parentWindow:MinigameWindow;
      
      private var m_prizeLevel:int = 0;
      
      private var m_price:int = 0;
      
      private var m_redeemableFeatureData:RedeemablesFeatureData = null;
      
      public function RedeemableSlot(element:DisplayObject, parentWindow:FarmWindow)
      {
         super(element);
         if(parentWindow is MinigameWindow)
         {
            this.m_parentWindow = parentWindow as MinigameWindow;
            this.m_redeemableFeatureData = this.m_parentWindow.redeemablesFeatureData;
            if(m_element.name_tf != null)
            {
               addWidget(new ZwTextField(m_element.name_tf));
            }
            if(m_element.icon_mc != null)
            {
               addWidget(new FarmIcon(m_element.icon_mc));
            }
            if(m_element.tickets_tf != null)
            {
               addWidget(new ZwTextField(m_element.tickets_tf,""));
            }
            if(m_element.effect_mc)
            {
               addWidget(new ZwFrame(m_element.effect_mc));
            }
            if(m_element.redeem_bt != null)
            {
               addWidget(new FarmAnimatedTextButton(m_element.redeem_bt,this.m_redeemableFeatureData.getRedeemButtonText(),this.onRedeem));
            }
         }
         else
         {
            ErrorManager.addError("RedeemableSlot, constructor() error: parentWindow is not type MinigameWindow.");
         }
      }
      
      public function grayOutRedeemButton(value:Boolean) : void
      {
         var effect:MovieClip = null;
         var redeemButton:FarmAnimatedButton = getWidget(m_element.redeem_bt) as FarmAnimatedButton;
         redeemButton.applyGrayOut = value;
         redeemButton.enabled = !value;
         if(m_element.effect_mc)
         {
            effect = m_element.effect_mc;
            if(!value)
            {
               effect.gotoAndPlay(2);
            }
            effect.visible = !value;
         }
      }
      
      private function onRedeem(event:Event = null) : void
      {
         var redeemTransaction:TGenericTransaction = new TGenericTransaction("RedeemablesFeatureService","redeemTickets",this.prizeResult,[this.m_parentWindow.minigameData.name,this.m_prizeLevel]);
         this.m_parentWindow.redeemPrize(this.m_price);
         this.displayRedeemingUpdate();
         TransactionManager.addTransaction(redeemTransaction,true);
      }
      
      private function displayRedeemingUpdate() : void
      {
         var midPoint:Point = null;
         var message:String = null;
         var halfButtonWidth:Number = NaN;
         if(Boolean(this) && Boolean(m_element))
         {
            midPoint = new Point(0,0);
            midPoint = m_element.redeem_bt.localToGlobal(midPoint);
            message = this.m_redeemableFeatureData.getRedeemingText();
            halfButtonWidth = m_element.redeem_bt.width * 0.5;
            UI.displayStatus(message,midPoint.x + halfButtonWidth,midPoint.y);
         }
      }
      
      private function prizeResult(result:Object) : void
      {
         this.m_parentWindow.prizeResult(result);
      }
      
      override public function populate(data:Object) : void
      {
         var prizeTitle:ZwTextField = null;
         var prizeIcon:FarmIcon = null;
         var prizePrice:ZwTextField = null;
         var redeemButton:FarmAnimatedButton = null;
         super.populate(data);
         if(m_element.name_tf != null)
         {
            prizeTitle = getWidget(m_element.name_tf) as ZwTextField;
            prizeTitle.text = data["title"];
            prizeTitle.visible = true;
         }
         if(m_element.icon_mc != null)
         {
            prizeIcon = getWidget(m_element.icon_mc) as FarmIcon;
            prizeIcon.loadIcon(data["icon"]);
            prizeIcon.visible = true;
         }
         if(m_element.tickets_tf != null)
         {
            prizePrice = getWidget(m_element.tickets_tf) as ZwTextField;
            this.m_price = data["price"];
            prizePrice.text = this.m_redeemableFeatureData.getRedeemPriceText(this.m_price);
            prizePrice.visible = true;
         }
         if(m_element.redeem_bt != null)
         {
            redeemButton = getWidget(m_element.redeem_bt) as FarmAnimatedButton;
            redeemButton.visible = true;
            this.grayOutRedeemButton(!this.m_parentWindow.canAfford(this.m_price) || this.m_parentWindow.redeemPrizesLocked);
         }
         this.m_prizeLevel = data["level"];
      }
      
      override public function release() : void
      {
         this.m_parentWindow = null;
         super.release();
      }
   }
}

