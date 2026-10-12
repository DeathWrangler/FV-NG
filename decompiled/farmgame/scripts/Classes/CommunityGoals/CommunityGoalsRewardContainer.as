package Classes.CommunityGoals
{
   import Classes.ImageLoader;
   import Classes.ZItem.FarmItem;
   import Classes.util.ZLocUtils;
   import Managers.CommunityGoalsManager;
   import Managers.TemplateUIUtility;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import Widgets.Icons.FarmIcon;
   import Widgets.Tooltips.FarmTextTooltip;
   import flash.display.DisplayObject;
   import flash.display.MovieClip;
   
   public class CommunityGoalsRewardContainer extends ZwFrame
   {
      
      private var m_icon_mc:FarmIcon;
      
      private var m_rewardText_tf:ZwTextField;
      
      private var m_quantity_tf:ZwTextField;
      
      private var m_itemName_tf:ZwTextField;
      
      private var m_showItemName:Boolean = false;
      
      private var m_slotBG:DisplayObject;
      
      private var placeHolderImageURL:String = "assets/hud/hud_icon_queue/hudicon_xsh_CommunityGoals.png";
      
      private const SLOT_MC_NAME:String = "mc_Slot_V_0";
      
      public function CommunityGoalsRewardContainer(reward:XML, rewardMC:MovieClip, showItemName:Boolean = false)
      {
         super(rewardMC);
         this.m_showItemName = showItemName;
         this.initializeRewardMC(reward,rewardMC);
      }
      
      private function initializeRewardMC(reward:XML, mc:MovieClip) : void
      {
         var verticalSlotBGPath:String = null;
         var iconMC:MovieClip = null;
         var imageUrl:String = null;
         if(mc)
         {
            if(mc.icon_mc)
            {
               iconMC = mc.icon_mc as MovieClip;
               imageUrl = this.placeHolderImageURL;
               this.m_icon_mc = new FarmIcon(iconMC,imageUrl);
               addWidget(this.m_icon_mc);
               this.m_icon_mc.visible = false;
            }
            if(mc.rewardText_tf)
            {
               this.m_rewardText_tf = new ZwTextField(mc.rewardText_tf,"Item Name");
               addWidget(this.m_rewardText_tf,true);
               this.m_rewardText_tf.visible = false;
            }
            if(mc.quantity_tf)
            {
               this.m_quantity_tf = new ZwTextField(mc.quantity_tf,"x0");
               addWidget(this.m_quantity_tf,true);
               this.m_quantity_tf.visible = false;
            }
            if(mc.itemName_tf)
            {
               this.m_itemName_tf = new ZwTextField(mc.itemName_tf,"Item Name",true);
               addWidget(this.m_itemName_tf,true);
               this.m_itemName_tf.visible = false;
            }
            verticalSlotBGPath = Global.worldSettingsManager.getSlotBGImagePath("V55");
            if(verticalSlotBGPath)
            {
               ImageLoader.getInstance(Global.getAssetURL(verticalSlotBGPath)).getContent(this.onSlotUrlLoaded);
               if(Boolean(this.m_slotBG) && mc.hasOwnProperty(this.SLOT_MC_NAME))
               {
                  mc[this.SLOT_MC_NAME].addChildAt(this.m_slotBG,1);
                  mc[this.SLOT_MC_NAME].removeChildAt(0);
                  mc[this.SLOT_MC_NAME].visible = true;
               }
            }
            if(TemplateUIUtility.isTemplateUIEnabled(TemplateUIUtility.EXPANSION))
            {
               TemplateUIUtility.applyExpansionSubTextColor(mc.rewardText_tf);
               TemplateUIUtility.applyExpansionGlowFilter(mc.itemName_tf);
            }
            this.refreshMC(reward);
         }
      }
      
      private function onSlotUrlLoaded(dispObj:DisplayObject, info:Object = null) : void
      {
         this.m_slotBG = dispObj;
      }
      
      public function refreshMC(reward:XML) : void
      {
         var farmItem:FarmItem = null;
         var imageUrl:String = null;
         if(this.m_icon_mc)
         {
            this.m_icon_mc.visible = false;
         }
         if(this.m_rewardText_tf)
         {
            this.m_rewardText_tf.visible = false;
         }
         if(reward.@type == CommunityGoalsManager.REWARD_PLAYER || reward.@type == CommunityGoalsManager.REWARD_COMMUNITY)
         {
            farmItem = Global.farmGameSettingsManager.getFarmItemByName(reward.@name);
            if(farmItem)
            {
               if(this.m_icon_mc)
               {
                  imageUrl = farmItem.getImageByName("feed");
                  if(imageUrl)
                  {
                     this.m_icon_mc.loadIcon(imageUrl);
                     this.m_itemName_tf.text = farmItem.friendlyTitle;
                     if(this.m_showItemName)
                     {
                        this.m_itemName_tf.visible = true;
                     }
                  }
               }
               this.detachTooltip();
               if(reward.@type == CommunityGoalsManager.REWARD_COMMUNITY)
               {
                  this.attachTooltip(new FarmTextTooltip(ZLocUtils.t("Items",farmItem.name + "Message")));
               }
               else if(reward.@type == CommunityGoalsManager.REWARD_PLAYER)
               {
                  this.attachTooltip(new FarmTextTooltip(farmItem.friendlyTitle));
               }
            }
            this.m_rewardText_tf.visible = false;
            this.m_icon_mc.visible = true;
         }
         if(Number(reward.@qty) > 1)
         {
            this.m_quantity_tf.text = "x" + reward.@qty;
            this.m_quantity_tf.visible = true;
         }
         else
         {
            this.m_quantity_tf.visible = false;
         }
      }
   }
}

