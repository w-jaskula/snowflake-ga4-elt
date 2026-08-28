import streamlit as st
from connection import get_connection
from connection import load_data

session = get_connection()
data = load_data(session)

df_device = data["device"]
df_geo = data["geo"]
df_daily = data["daily"]
df_kpis = data["kpis"]

# ==========================================
# HEADER & CONTEXT
# ==========================================

st.title(f"GA4 E-Commerce & User Engagement Overview")
st.write(
    """This dashboard presents aggregated product and geographical analytics powered by data from the gold layer in Snowflake. It enables clear tracking of user engagement, key market performance, and event dynamics over time.
    """
)

st.markdown("""
- :file_folder: [GitHub Repository](https://github.com/w-jaskula/snowflake-streamlit-pipeline)
- :books: [Data Source: Google Analytics 4 Public Sample Dataset](https://www.kaggle.com/datasets/pdaasha/ga4-obfuscated-sample-ecommerce-jan2021?resource=download)
""")

st.divider()

# ==========================================
# KPI CARDS
# ==========================================
total_events = df_kpis["TOTAL_EVENTS"].iloc[0]
unique_users = df_kpis["UNIQUE_USERS"].iloc[0]
avg_engagement = df_kpis["AVG_ENGAGEMENT_SECONDS"].iloc[0]

col1, col2, col3 = st.columns(3)
with col1:
    with st.container(border=True):
        st.metric(label="Total events", value=f"{total_events:,}")

with col2:
    with st.container(border=True):
        st.metric(label="Total unique users", value=f"{unique_users:,}")

with col3:
    with st.container(border=True):
        st.metric(label="Average engagement [sec]", value=f"{avg_engagement:,}")

# ==========================================
# TABS & VISUALIZATIONS
# ==========================================
tab1, tab2, tab3 = st.tabs(["📱 Device & OS Engagement", "🌍 Geographical Performance", "📈 Daily Event Dynamics"])

# ------------------------------------------
# 1. TAB DEVICE & OS ENGAGEMENT
# ------------------------------------------
with tab1:
    st.subheader("Device & OS Engagement Breakdown")

    col1, col2 = st.columns([1.2, 1])

    with col1:
        st.markdown("**Total Events by Operating System**")
        df_os_pivot = df_device.pivot_table(
            index="OPERATING_SYSTEM",
            columns="DEVICE_CATEGORY",
            values="TOTAL_EVENTS",
            aggfunc="sum",
            fill_value=0
        )

        df_os_pivot["TOTAL"] = df_os_pivot.sum(axis=1)
        df_os_pivot = df_os_pivot.sort_values(by="TOTAL", ascending=True).drop(columns=["TOTAL"])

        st.bar_chart(df_os_pivot, stack=True, horizontal=True)

    with col2:
        st.markdown("**Avg Engagement Time by Browser**")
        df_browser_clean = df_device[
            (df_device["AVG_ENGAGEMENT_SECONDS"].notna()) &
            (df_device["BROWSER"] != "<Other>")
            ]

        df_browser_eng = (
            df_browser_clean
            .groupby("BROWSER", as_index=False)["AVG_ENGAGEMENT_SECONDS"]
            .mean()
            .sort_values(by="AVG_ENGAGEMENT_SECONDS", ascending=True)
        )

        st.bar_chart(
            df_browser_eng,
            x="BROWSER",
            y="AVG_ENGAGEMENT_SECONDS",
            horizontal=True
        )

    with st.expander("📄 Show raw data table"):
        st.dataframe(df_device, use_container_width=True)

# ------------------------------------------
# 2. TAB GEOGRAPHICAL PERFORMANCE
# ------------------------------------------
with tab2:
    st.subheader("Geographical Performance")

    df_geo_pivoted = df_geo.pivot(
        index="COUNTRY",
        columns="CITY",
        values="UNIQUE_USERS"
    ).fillna(0)

    df_geo_pivoted["TOTAL"] = df_geo_pivoted.sum(axis=1)
    df_geo_pivoted = df_geo_pivoted.sort_values(by="TOTAL", ascending=False).drop(columns=["TOTAL"])

    col1, col2 = st.columns([2, 1])

    with col1:
        st.markdown("**Users Breakdown by Country & City**")
        st.bar_chart(df_geo_pivoted, stack=True, horizontal=True)

    with col2:
        st.markdown("**Top Market Share**")
        st.dataframe(
            df_geo[["COUNTRY", "CITY", "UNIQUE_USERS"]].sort_values(by="UNIQUE_USERS", ascending=True),
            use_container_width=True,
            hide_index=True
        )

    with st.expander("📄 Show raw data table"):
        st.dataframe(df_geo, use_container_width=True, hide_index=True)

# ------------------------------------------
# 3. TAB DAILY EVENT DYNAMICS
# ------------------------------------------
with tab3:
    st.subheader("Available events by date")
    available_events = df_daily["EVENT_NAME"].unique()
    selected_event = st.selectbox(
        label="Select Event Name:",
        options=available_events
    )
    df_daily_filtered = df_daily[df_daily["EVENT_NAME"] == selected_event]
    st.line_chart(
        df_daily_filtered,
        x="EVENT_DATE",
        y="TOTAL_EVENTS"
    )

    st.subheader("Unique users per event")
    df_daily_grouped = (
        df_daily
        .groupby("EVENT_NAME", as_index=False)["UNIQUE_USERS"]
        .sum()
        .sort_values(by="EVENT_NAME", ascending=True)
    )

    st.bar_chart(
        df_daily_grouped,
        x="EVENT_NAME",
        y="UNIQUE_USERS"
    )

    with st.expander("📄 Show raw data table"):
        st.dataframe(df_daily, use_container_width=True)