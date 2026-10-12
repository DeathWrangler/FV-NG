package Widgets.Frames.Crafting
{
   import Classes.Friend;
   import Classes.Player;
   import Classes.util.ZLocUtils;
   import Widgets.Core.Base.ZwWidget;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObject;
   
   public class CraftshopRecipeCrewFrame extends ZwFrame
   {
      
      protected var m_image:FarmIcon;
      
      protected var m_name:ZwTextField;
      
      protected var m_background:ZwWidget;
      
      private var m_rolloverTooltip:FarmTextTooltip = null;
      
      public function CraftshopRecipeCrewFrame(element:DisplayObject)
      {
         super(element);
         this.m_background = addWidget(new ZwWidget(this.element.bg_mc),false) as ZwWidget;
         this.m_image = addWidget(new FarmIcon(this.element.icon_mc,Player.NO_PROFILE_PIC_URL),false) as FarmIcon;
         this.m_name = addWidget(new ZwTextField(this.element.name_tf,""),false) as ZwTextField;
         this.m_rolloverTooltip = new FarmTextTooltip();
         this.attachTooltip(this.m_rolloverTooltip);
      }
      
      public function update(uid:String) : void
      {
         this.m_widgetManager.hideAllWidgets();
         this.visible = true;
         this.m_background.visible = true;
         var friendObj:Friend = Global.friendManager.getAppFriendData(uid);
         if(Boolean(friendObj) && Boolean(friendObj.firstName) && Boolean(friendObj.picture))
         {
            this.m_image.loadIcon(friendObj.picture);
            this.m_image.setIconSize(50,50);
            this.m_image.visible = true;
            this.m_name.text = friendObj.firstName;
            this.m_name.visible = true;
            this.m_rolloverTooltip.setText("");
         }
         else
         {
            this.m_image.loadIcon(Player.NO_PROFILE_PIC_URL);
            this.m_image.setIconSize(50,50);
            this.m_image.visible = true;
            this.m_rolloverTooltip.setText(ZLocUtils.t("Crafting","CraftingMain_RecipeSlot_FriendIcon_Tooltip"));
         }
      }
   }
}

