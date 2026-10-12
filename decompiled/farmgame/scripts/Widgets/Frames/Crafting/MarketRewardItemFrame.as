package Widgets.Frames.Crafting
{
   import Classes.util.ZLocUtils;
   import Widgets.Buttons.FarmAnimatedTextButton;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import flash.display.DisplayObject;
   
   public class MarketRewardItemFrame extends ZwFrame
   {
      
      public function MarketRewardItemFrame(element:DisplayObject, iconUrl:String, message:String, selectCallback:Function)
      {
         super(element);
         var icon:FarmIcon = new FarmIcon(this.element.rewardIcon_mc,iconUrl);
         icon.setIconSize(50,50);
         addWidget(icon);
         addWidget(new ZwTextField(this.element.cropType_tf,message));
         addWidget(new FarmAnimatedTextButton(this.element.select_bt,ZLocUtils.t("Crafting","MarketRewardDialog_Select"),selectCallback));
      }
   }
}

