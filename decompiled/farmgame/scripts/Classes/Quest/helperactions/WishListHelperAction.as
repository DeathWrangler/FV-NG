package Classes.Quest.helperactions
{
   import Classes.FarmSocialNetwork;
   import Classes.util.ZLocUtils;
   
   public class WishListHelperAction extends ItemHelperAction
   {
      
      public function WishListHelperAction(questName:String, itemName:String)
      {
         super(questName,itemName);
      }
      
      override public function perform() : void
      {
         super.perform();
         if(Global.farmSocialNetwork.getSocialNetworkId() == FarmSocialNetwork.SNID_FACEBOOK)
         {
            Global.farmSocialNetwork.farmRedirect("gifts.php?template=wishlist&ref=gift_box");
         }
         else
         {
            GlobalEngine.socialNetwork.redirect("gifts.php?ref=zlive");
         }
      }
      
      override public function get readableText() : String
      {
         return ZLocUtils.t("Quests","Helper_WishList_Button");
      }
   }
}

