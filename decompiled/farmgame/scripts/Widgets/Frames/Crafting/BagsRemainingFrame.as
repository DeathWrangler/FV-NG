package Widgets.Frames.Crafting
{
   import Classes.util.ZLocUtils;
   import Managers.Crafting.CraftingManager;
   import Widgets.Core.Frames.ZwFrame;
   import Widgets.Core.TextFields.ZwTextField;
   import flash.display.MovieClip;
   
   public class BagsRemainingFrame extends ZwFrame
   {
      
      private var m_purchaseLimitTextField:ZwTextField;
      
      private var m_purchaseCounterTextField:ZwTextField;
      
      private var m_uid:String;
      
      private var m_craftedGoods:Boolean = false;
      
      public function BagsRemainingFrame(element:MovieClip, uid:String, craftedGoods:Boolean = false)
      {
         var purchaseLimit:int = 0;
         var bagsRemaining:int = 0;
         super(element);
         this.m_uid = uid;
         this.m_craftedGoods = craftedGoods;
         if(this.m_craftedGoods)
         {
            purchaseLimit = Global.player.craftingState.shoppingState.maxCraftingBagsPerUser;
            bagsRemaining = CraftingManager.getInstance().getCraftingBagsAvailableByUser(this.m_uid);
         }
         else
         {
            purchaseLimit = Global.player.craftingState.shoppingState.maxBagsPerUser;
            bagsRemaining = CraftingManager.getInstance().getBagsAvailableByUser(this.m_uid);
         }
         this.m_purchaseLimitTextField = new ZwTextField(m_element.generic_tf,ZLocUtils.t("Crafting","FriendFarmersMarketDialog_PerUserPurchaseLimit",{"quantity":purchaseLimit}));
         addWidget(this.m_purchaseLimitTextField);
         this.m_purchaseCounterTextField = new ZwTextField(m_element.generic2_tf,ZLocUtils.t("Crafting","FriendFarmersMarketDialog_PerUserPurchaseCounter",{"quantity":bagsRemaining}));
         addWidget(this.m_purchaseCounterTextField);
      }
      
      public function set isRenderingCraftedGoods(newRenderingCraftedGoods:Boolean) : void
      {
         this.m_craftedGoods = newRenderingCraftedGoods;
      }
      
      public function refresh() : void
      {
         var purchaseLimit:int = 0;
         var bagsRemaining:int = 0;
         if(this.m_craftedGoods)
         {
            purchaseLimit = Global.player.craftingState.shoppingState.maxCraftingBagsPerUser;
            bagsRemaining = CraftingManager.getInstance().getCraftingBagsAvailableByUser(this.m_uid);
         }
         else
         {
            purchaseLimit = Global.player.craftingState.shoppingState.maxBagsPerUser;
            bagsRemaining = CraftingManager.getInstance().getBagsAvailableByUser(this.m_uid);
         }
         this.m_purchaseLimitTextField.text = ZLocUtils.t("Crafting","FriendFarmersMarketDialog_PerUserPurchaseLimit",{"quantity":purchaseLimit});
         this.m_purchaseCounterTextField.text = ZLocUtils.t("Crafting","FriendFarmersMarketDialog_PerUserPurchaseCounter",{"quantity":bagsRemaining});
      }
      
      override public function release() : void
      {
         super.release();
         this.m_purchaseLimitTextField = null;
         this.m_purchaseCounterTextField = null;
      }
   }
}

