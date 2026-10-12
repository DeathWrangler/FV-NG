package Transactions
{
   import Classes.Pet;
   import Classes.PetConfig;
   import Classes.ZItem.PetFarmItem;
   import Classes.util.ZLocUtils;
   
   public class TPetsPlace extends TPlace
   {
      
      private const CONSUME_KIBBLE:String = "consume_kibble";
      
      public function TPetsPlace(pet:Pet)
      {
         super(pet);
         m_params.isGift = false;
         m_params.isStorageWithdrawal = 0;
         if(pet.petName.length > 0)
         {
            m_params.petName = pet.petName;
         }
         else
         {
            m_params.petName = ZLocUtils.t("Dialogs","PetDefaultName");
         }
         m_params.petType = pet.getItem().code;
         m_params.petGender = pet.petGender;
      }
      
      override protected function onComplete(result:Object) : void
      {
         var petItem:PetFarmItem = null;
         super.onComplete(result);
         var pet:Pet = m_object as Pet;
         if(pet)
         {
            petItem = PetConfig.getPetItem(pet.getItem().name);
            if(petItem.kibbleBonus)
            {
               Global.player.addGift(this.CONSUME_KIBBLE,"0",petItem.kibbleBonus);
            }
         }
      }
      
      override public function getTransactionData() : Object
      {
         var result:Object = super.getTransactionData();
         result.isStorageWithdrawl = m_params.isStorageWithdrawal;
         return result;
      }
   }
}

