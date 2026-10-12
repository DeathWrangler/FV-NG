package Classes.consumables
{
   import Classes.Consumable;
   import Managers.OrderBoard.HalloweenInnovationManager;
   
   public class CHalloweenUSARedeemConsumable extends Consumable
   {
      
      public function CHalloweenUSARedeemConsumable(itemName:String)
      {
         super(itemName);
      }
      
      override public function consume(isGift:Boolean = true, allowReshopping:Boolean = true, userID:String = "", isFree:Boolean = false, storageId:int = -1, itemCount:int = 1) : void
      {
         var category:String = null;
         switch(m_itemName)
         {
            case "consume_xha_animal_redeem":
               category = "HalloweenInnovationRedeemAnimals";
               break;
            case "consume_xha_tree_redeem":
               category = "HalloweenInnovationRedeemTrees";
               break;
            case "consume_xha_deco_redeem":
               category = "HalloweenInnovationRedeemDecos";
               break;
            case "consume_xha_building_redeem":
               category = "HalloweenInnovationRedeemBuildings";
               break;
            default:
               category = "HalloweenInnovationRedeemAnimals";
         }
         HalloweenInnovationManager.getInstance().openRedeemWindow(category,m_itemName);
      }
   }
}

