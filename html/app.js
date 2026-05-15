const state = {
    buyer: null,
    drugs: [],
    selected: null,
    quantity: 1,
    price: 0,
    isDay: true,
    levelBonus: 0,
    level: 1,
    xp: 0,
};

const q = id => document.getElementById(id);
const app = q('app');

let lang = {};
function L(key, vars) {
    let s = lang[key] || key;
    if (vars) for (const [k, v] of Object.entries(vars)) s = s.replaceAll(`{${k}}`, v);
    return s;
}

const fmt = n => '$' + Math.round(n).toLocaleString('en-US');
const clamp = (v, a, b) => Math.max(a, Math.min(b, v));

function calcPriceModifier(drug, price) {
    if (!drug) return 0;
    const bonus = drug.priceChanceBonus || 15;
    const base = drug.basePrice;
    if (price <= base) {
        const range = base - drug.priceMin;
        if (range <= 0) return 0;
        return Math.round(((base - price) / range) * bonus);
    } else {
        const range = drug.priceMax - base;
        if (range <= 0) return 0;
        return -Math.round(((price - base) / range) * bonus);
    }
}

function calcChance(drug, qty, price, isDay, levelBonus) {
    if (!drug) return 0;
    let c = drug.baseChance;
    if (qty > 1) c -= (qty - 1) * drug.chancePerExtra;
    c += isDay ? (drug.dayBonus || 0) : (drug.nightBonus || 0);
    c += levelBonus || 0;
    c += calcPriceModifier(drug, price);
    return clamp(Math.round(c), 0, 100);
}

function updateChanceUI() {
    const d = state.selected;
    if (!d) return;

    const chance = calcChance(d, state.quantity, state.price, state.isDay, state.levelBonus);
    const priceMod = calcPriceModifier(d, state.price);

    q('chance-fill').style.width = chance + '%';
    q('chance-pct').textContent = chance + '%';
    q('price-val').textContent = fmt(state.price);

    const card = q('chance-track').closest('.neg-card');
    card.classList.remove('c-low', 'c-mid', 'c-ok', 'c-high');
    if (chance >= 70) card.classList.add('c-high');
    else if (chance >= 45) card.classList.add('c-ok');
    else if (chance >= 25) card.classList.add('c-mid');
    else card.classList.add('c-low');

    const timeBonus = state.isDay ? (d.dayBonus || 0) : (d.nightBonus || 0);
    const tagTime = q('tag-time');
    if (timeBonus > 0) {
        tagTime.textContent = `+${timeBonus}% ${state.isDay ? 'den' : 'noc'}`;
        tagTime.className = 'tag tag-green';
        tagTime.classList.remove('hidden');
    } else {
        tagTime.classList.add('hidden');
    }

    const tagPrice = q('tag-price');
    if (priceMod > 0) {
        tagPrice.textContent = `+${priceMod}% nízká cena`;
        tagPrice.className = 'tag tag-green';
    } else if (priceMod < 0) {
        tagPrice.textContent = `${priceMod}% vysoká cena`;
        tagPrice.className = 'tag tag-red';
    } else {
        tagPrice.textContent = L('ui_no_affect') || 'Base price';
        tagPrice.className = 'tag tag-gray';
    }

    const tagLvl = q('tag-level');
    if (state.levelBonus > 0) {
        tagLvl.textContent = `+${state.levelBonus}% LVL ${state.level}`;
        tagLvl.className = 'tag tag-green';
        tagLvl.classList.remove('hidden');
    } else {
        tagLvl.classList.add('hidden');
    }
}

function updateTotal() {
    const d = state.selected; if (!d) return;
    const el = q('sel-total');
    el.textContent = fmt(state.price * state.quantity);
    el.classList.remove('total-flash');
    void el.offsetWidth;
    el.classList.add('total-flash');
}

function updateQtyUI() {
    const d = state.selected; if (!d) return;
    const max = Math.min(d.maxUnits, d.count);

    const numEl = q('qty-num');
    numEl.textContent = state.quantity;
    numEl.classList.remove('num-flash');
    void numEl.offsetWidth;
    numEl.classList.add('num-flash');

    q('qty-stock').textContent = `${d.count} skladem`;
    q('qty-hint-text').textContent = `-${d.chancePerExtra}% za každý extra kus`;

    q('qty-minus').disabled = state.quantity <= (d.minQuantity || 1);
    q('qty-plus').disabled = state.quantity >= max;

    updateTotal();
    updateChanceUI();
}

function renderDrugList() {
    const list = q('drug-list');
    list.innerHTML = '';
    state.drugs.forEach(drug => {
        const el = document.createElement('div');
        el.className = 'drug-item';
        el.innerHTML = `
            <i class="fa-solid fa-circle-dot d-icon"></i>
            <div class="d-body">
                <div class="d-name">${drug.label}</div>
                <div class="d-count">${drug.count} piece${drug.count !== 1 ? 's' : ''} available</div>
            </div>
            <span class="d-price mono">${fmt(drug.basePrice)}</span>
        `;
        el.addEventListener('click', () => selectDrug(drug));
        list.appendChild(el);
    });
}

function selectDrug(drug) {
    state.selected = drug;
    state.quantity = drug.minQuantity || 1;
    state.price = drug.basePrice;

    q('sel-label').textContent = drug.label;
    q('sel-sub').textContent = `BASE ${fmt(drug.basePrice)}`;

    const slider = q('price-slider');
    slider.min = drug.priceMin;
    slider.max = drug.priceMax;
    slider.value = drug.basePrice;
    q('price-min').textContent = fmt(drug.priceMin);
    q('price-max').textContent = fmt(drug.priceMax);

    q('lbl-chance').textContent = L('ui_success_chance') || 'SUCCESS CHANCE';
    q('lbl-price').textContent = L('ui_price_piece') || 'PRICE / UNIT';
    q('lbl-qty').textContent = L('ui_quantity') || 'QUANTITY';
    q('lbl-reject').textContent = L('ui_reject') || 'Reject';
    q('lbl-offer').textContent = L('ui_make_offer') || 'Make Offer';

    updateQtyUI();

    q('panel-select').classList.add('hidden');
    const neg = q('panel-negotiate');
    neg.classList.remove('hidden');
    neg.classList.add('panel-enter');
    setTimeout(() => neg.classList.remove('panel-enter'), 200);
}

function openUI(data) {
    state.buyer = data.buyer;
    state.drugs = data.drugs || [];
    state.isDay = data.isDay ?? true;
    state.selected = null;

    q('npc-label').textContent = data.buyer.label || '';
    q('quote-text').textContent = data.buyer.quote || '';
    q('lbl-what').textContent = L('ui_select_drug') || 'WHAT DO YOU HAVE?';

    renderDrugList();
    q('panel-negotiate').classList.add('hidden');
    q('panel-select').classList.remove('hidden');
    app.classList.remove('hidden');
}

function closeUI() {
    app.classList.add('hidden');
    state.selected = null;
    postGame('close', {});
}

function postGame(action, data) {
    fetch(`https://rs_drugsell2/${action}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data),
    }).catch(() => { });
}

q('btn-close').addEventListener('click', closeUI);
q('btn-reject').addEventListener('click', closeUI);

q('price-slider').addEventListener('input', e => {
    state.price = parseInt(e.target.value);
    updateTotal();
    updateChanceUI();
});

q('qty-minus').addEventListener('click', () => {
    const d = state.selected; if (!d) return;
    if (state.quantity > (d.minQuantity || 1)) { state.quantity--; updateQtyUI(); }
});
q('qty-plus').addEventListener('click', () => {
    const d = state.selected; if (!d) return;
    if (state.quantity < Math.min(d.maxUnits, d.count)) { state.quantity++; updateQtyUI(); }
});

q('btn-offer').addEventListener('click', () => {
    const d = state.selected; if (!d) return;
    postGame('makeoffer', {
        item: d.item,
        quantity: state.quantity,
        price: state.price,
        chance: calcChance(d, state.quantity, state.price, state.isDay, state.levelBonus),
    });
});

window.addEventListener('message', ({ data }) => {
    if (data.action === 'setLocale') { lang = data.lang || {}; }
    else if (data.action === 'open') { openUI(data); }
    else if (data.action === 'close') { app.classList.add('hidden'); }
    else if (data.action === 'xpData') {
        state.xp = data.xp || 0;
        state.level = data.level || 1;
        let bonus = 0;
        for (const [lvl, d] of Object.entries(data.levels || {})) {
            if (state.xp >= d.xpRequired && parseInt(lvl) <= state.level) bonus = d.bonus || 0;
        }
        state.levelBonus = bonus;
        if (!q('panel-negotiate').classList.contains('hidden')) updateChanceUI();
    }
});

document.addEventListener('keydown', e => { if (e.key === 'Escape') closeUI(); });
